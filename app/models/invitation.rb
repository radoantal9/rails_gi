class Invitation < ActiveRecord::Base
  include PgSearch

  # Search
  multisearchable :against => [:invitation_email]

  PgSearch.multisearch_options = {
      :using => { :tsearch => {:prefix => true}}
  }

  # Relations
  belongs_to :orgs_course
  belongs_to :invited_user, class_name: 'User', foreign_key: :user_id

  # Scopes
  scope :by_org_course, ->(org_course) { where(orgs_course_id: org_course) }
  scope :by_email, ->(email) { where(invitation_email: email.downcase) }
  scope :by_token, ->(token) { where(invitation_token: token) }
  scope :accepted, -> { with_invitation_state(:invitation_accepted) }
  scope :not_accepted, -> { where('invitation_state != ? AND invitation_state != ?', :invitation_accepted, :invitation_deactivated) }

  # Fields
  attr_accessible :orgs_course, :invitation_email
  normalize_attributes(:invitation_email, before: [:strip, :blank]) {|val| val.try :downcase }

  # Validations
  validates :orgs_course, presence: true
  validates :invitation_email, email: true, presence: true
  validates :invitation_token, presence: true, uniqueness: true

  # States
  state_machine :invitation_state, initial: :invitation_created do
    state :invitation_created
    state :invitation_sent
    state :invitation_viewed
    state :invitation_accepted
    state :invitation_failed
    state :invitation_deactivated

    event :send_invitation do
      transition :invitation_created => :invitation_sent
    end

    event :view_invitation do
      transition [:invitation_created, :invitation_sent] => :invitation_viewed
    end

    event :reset_invitation do
      transition [:invitation_created, :invitation_sent, :invitation_viewed, :invitation_failed] => :invitation_created
    end

    event :fail_invitation do
      transition all => :invitation_failed
    end

    event :deactivate_invitation do
      transition [:invitation_created, :invitation_sent, :invitation_viewed, :invitation_failed] => :invitation_deactivated
    end

    event :activate_invitation do
      transition :invitation_deactivated => :invitation_created
    end

    event :accept_invitation do
      transition [:invitation_created, :invitation_sent, :invitation_viewed, :invitation_deactivated] => :invitation_accepted
    end

    before_transition any => :invitation_sent do |obj|
      obj.sent_at = Time.now
      obj.increment :sent_count
    end

    after_transition any => [:invitation_sent, :invitation_viewed, :invitation_accepted, :invitation_deactivated] do |obj|
      UserEvent.create user: obj.invited_user, email: obj.invitation_email, course: obj.orgs_course.course, event_type: obj.invitation_state
    end
  end

  # Callbacks
  before_validation do
    unless invitation_token
      begin
        self.invitation_token = SecureRandom.hex(16)
      end while self.class.exists?(invitation_token: self.invitation_token)
    end
  end

  # Create and send invitation
  def self.find_or_create_invitation(org, course, email)
    orgs_course = OrgsCourse.where(org_id: org, course_id: course).first
    inv = orgs_course.invitations.by_email(email).first
    inv ||= Invitation.create(orgs_course: orgs_course, invitation_email: email.downcase)
    inv.reset_invitation
    inv
  end

  # Returns list of good/bad emails
  def self.create_invitations(org, course, emails_str, manager = nil)
    res = { ignored: [], enrolled: [], invited: [], error: [] }

    emails_str.split("\n").each do |email|
      email = email.strip.downcase
      next if email.blank?

      user = User.by_email(email).first
      if user
        if user.org != org || user.courses.include?(course)
          res[:ignored] << email
        else
          # Subscribe to the course and send welcome email
          user.courses << course
          Delayed::Job.enqueue CourseEnrollmentJob.new(course.id, user.id)
          res[:enrolled] << email
        end
      else
        # Send invitation
        inv = Invitation.find_or_create_invitation(org, course, email)
        if inv.persisted?
          if inv.can_send_invitation?
            Delayed::Job.enqueue InvitationJob.new(inv.id)
            res[:invited] << email
          else
            res[:ignored] << email
          end
        else
          # Bad email address
          res[:error] << email
        end
      end
    end

    # Send statistics
    if manager
      NotificationMailer.mailing_stats(manager, course, 'Invitation Sending Stats', res).deliver
    end

    res
  end

  # Accept invitation if user exists
  def self.update_invitation_state(email)
    user = User.by_email(email).first
    if user
      Invitation.by_email(email).update_all invitation_state: 'invitation_accepted', user_id: user
    end
  end

  def self.invitation_state_list
    Invitation.state_machines[:invitation_state].states.map do |s|
      s.name.to_s
    end
  end

  # Accept invitation by user email
  def self.check_enrollment(user)
    Invitation.by_email(user.email).each do |inv|
      if inv.can_accept_invitation?
        inv.invited_user = user
        inv.accept_invitation
        inv.save
      end

      if user.org == inv.orgs_course.org
        unless user.courses.include? inv.orgs_course.course
          user.courses << inv.orgs_course.course
        end
      end
    end
  rescue => ex
    Rails.logger.error ex.inspect
    Rails.logger.error ex.backtrace.join("\n")
  end

  # Returns list of resend emails
  def self.resend_invitations(org, course, manager = nil, custom_email_subject = nil, custom_email_message = nil)
    res = { custom_email_subject: [], custom_email_message: [], resend: [] }
    orgs_course = org.orgs_courses.by_course(course).first

    if custom_email_subject.present?
      res[:custom_email_subject] << custom_email_subject
    else
      res[:custom_email_subject] << 'not set'
    end

    if custom_email_message.present?
      res[:custom_email_message] << custom_email_message
    else
      res[:custom_email_message] << 'not set'
    end

    orgs_course.invitations.not_accepted.each do |inv|
      if inv.can_reset_invitation?
        inv.reset_invitation
        Delayed::Job.enqueue InvitationJob.new(inv.id, custom_email_subject, custom_email_message)
        res[:resend] << inv.invitation_email
      end
    end

    # Send statistics
    if manager
      NotificationMailer.mailing_stats(manager, course, 'Resend invitations', res).deliver
    end

    res
  end
end
