class Survey < ActiveRecord::Base
  # Relations
  belongs_to :question
  belongs_to :question_response
  belongs_to :orgs_course
  belongs_to :user

  # Scopes
  scope :by_org_course, ->(org_course) { where(orgs_course_id: org_course) }
  scope :by_email, ->(email) { where(survey_email: email.downcase) }
  scope :by_question, ->(question) { where(question_id: question) }
  scope :by_user, ->(user) { where(user_id: user) }
  scope :by_token, ->(token) { where(survey_token: token) }

  # Fields
  attr_accessible :survey_email, :question, :user

  # Validations
  validates :question, :orgs_course, presence: true
  validates :survey_token, presence: true, uniqueness: true

  # States
  state_machine :survey_state, initial: :survey_created do
    state :survey_created
    state :survey_sent
    state :survey_viewed
    state :survey_opened
    state :survey_submitted
    state :survey_failed
    state :survey_deactivated

    event :send_survey do
      transition :survey_created => :survey_sent
    end

    event :view_survey do
      transition [:survey_created, :survey_sent] => :survey_viewed
    end

    event :open_survey do
      transition [:survey_created, :survey_sent, :survey_viewed] => :survey_opened
    end

    event :reset_survey do
      transition [:survey_created, :survey_sent, :survey_viewed, :survey_opened, :survey_failed] => :survey_created
    end

    event :fail_survey do
      transition all => :survey_failed
    end

    event :deactivate_survey do
      transition [:survey_created, :survey_sent, :survey_viewed, :survey_opened, :survey_failed] => :survey_deactivated
    end

    event :activate_survey do
      transition :survey_deactivated => :survey_created
    end

    event :submit_survey do
      transition [:survey_created, :survey_sent, :survey_viewed, :survey_opened] => :survey_submitted
    end

    before_transition any => :survey_sent do |obj|
      obj.sent_at = Time.now
      obj.increment :sent_count
    end
  end
  
  # Callbacks
  before_validation do
    unless survey_token
      begin
        self.survey_token = SecureRandom.hex(16)
      end while self.class.exists?(survey_token: self.survey_token)
    end
  end
  
  # Filter users
  def self.filter_users(org, course, params)
    users = org.users.by_course(course)

    if params[:completed] == '1' && params[:not_completed] == '1'
      return users
    elsif params[:completed] != '1' && params[:not_completed] != '1'
      return nil
    end

    users = users.select do |user|
      completion = course.user_completion(user)

      (params[:completed] == '1' && completion > 99) || (params[:not_completed] == '1' && completion <= 99)
    end

    User.where(id: users.map(&:id))
  end

  # Filter invitations
  def self.filter_invitations(org, course, params)
    org_course = course.orgs_courses.by_org(org).first

    if params[:invited] == '1'
      org_course.invitations.where(invitation_state: [:invitation_sent, :invitation_viewed])
    end
  end

  # Send
  def self.create_surveys(org, course, question, user_ids, invitation_ids)
    res = { ignored: [], created: [], resent: [], error: [] }
    orgs_course = OrgsCourse.by_org(org).by_course(course).first
    raise 'Org is not enrolled to Course' unless orgs_course

    user_ids.each do |user_id|
      user = org.users.find_by_id(user_id)
      create_survey(orgs_course, question, user.email, res)
    end

    invitation_ids.each do |invitation_id|
      inv = orgs_course.invitations.find_by_id(invitation_id)
      create_survey(orgs_course, question, inv.invitation_email, res)
    end

    res
  end

  def self.create_surveys_for_all_users(org, course, question, params, manager = nil)
    res = { ignored: [], created: [], resent: [], error: [] }
    orgs_course = OrgsCourse.by_org(org).by_course(course).first
    raise 'Org is not enrolled to Course' unless orgs_course

    users = Survey.filter_users(org, course, params)
    users && users.each do |user|
      create_survey(orgs_course, question, user.email, res)
    end

    invitations = Survey.filter_invitations(org, course, params)
    invitations && invitations.each do |inv|
      create_survey(orgs_course, question, inv.invitation_email, res)
    end

    # Send statistics
    if manager
      NotificationMailer.mailing_stats(manager, course, 'Create surveys', res).deliver
    end

    res
  end

  def self.create_survey(orgs_course, question, email, res)
    user = orgs_course.org.users.by_course(orgs_course.course).by_email(email).first
    if user || orgs_course.invitations.by_email(email).exists?
      survey = orgs_course.surveys.by_email(email).by_question(question).first

      if survey.try :survey_submitted?
        res[:ignored] << email
        return
      end

      if survey
        survey.reset_survey
        res[:resent] << email
      else
        survey = orgs_course.surveys.create! survey_email: email, question: question, user: user
        res[:created] << email
      end

      Delayed::Job.enqueue SurveyJob.new(survey.id)
    else
      res[:error] << email
    end
  end

  def self.survey_state_list
    self.state_machines[:survey_state].states.map do |s|
      s.name.to_s
    end
  end
end
