class Reminder < ActiveRecord::Base
  # Relations
  belongs_to :orgs_course
  belongs_to :user

  # Scopes
  scope :by_org_course, ->(org_course) { where(orgs_course_id: org_course) }
  scope :by_user, ->(user) { where(user_id: user) }
  scope :by_token, ->(token) { where(reminder_token: token) }

  # Fields
  attr_accessible :orgs_course, :user

  # Validations
  validates :orgs_course, :user, presence: true
  validates :reminder_token, presence: true, uniqueness: true

  # States
  state_machine :reminder_state, initial: :reminder_created do
    state :reminder_created
    state :reminder_sent
    state :reminder_viewed
    state :reminder_accepted
    state :reminder_failed
    state :reminder_completed

    event :send_reminder do
      transition :reminder_created => :reminder_sent
    end

    event :view_reminder do
      transition [:reminder_created, :reminder_sent] => :reminder_viewed
    end

    event :reset_reminder do
      transition [:reminder_sent, :reminder_viewed, :reminder_accepted, :reminder_failed] => :reminder_created
    end

    event :fail_reminder do
      transition all => :reminder_failed
    end

    event :complete_reminder do
      transition all => :reminder_completed
    end

    event :accept_reminder do
      transition [:reminder_created, :reminder_sent, :reminder_viewed] => :reminder_accepted
    end

    before_transition any => :reminder_sent do |obj|
      obj.sent_at = Time.now
      obj.increment :sent_count
    end

    after_transition any => [:reminder_sent, :reminder_viewed, :reminder_accepted] do |obj|
      obj.user.user_events.create! course: obj.orgs_course.course, event_type: obj.reminder_state
    end
  end

  # Callbacks
  before_validation do
    unless reminder_token
      begin
        self.reminder_token = SecureRandom.hex(16)
      end while self.class.exists?(reminder_token: self.reminder_token)
    end
  end
  
  # Filter users for reminder mails
  def self.filter_users(org, course, params)
    users = org.users.by_course(course)
    
    if params[:completion_gte].present? || params[:completion_lte].present? || params[:current_learning_module_id].present?
      users = users.select do |user|
        ok = true
        completion_gte = params[:completion_gte].to_i
        completion_lte = params[:completion_lte].to_i

        if completion_gte > 0 || completion_lte > 0
          completion = course.fitted_user_completion(user)

          if completion_gte > 0
            ok &&= completion >= completion_gte
          end

          if completion_lte > 0
            ok &&= completion <= completion_lte
          end
        end

        if ok && params[:current_learning_module_id].present?
          ok = course.current_learning_module(user).try(:id) == params[:current_learning_module_id].to_i
        end

        ok
      end

      users = User.where(id: users.map(&:id))
    end

    users
  end

  # Send
  def self.create_reminders(org, course, user_ids)
    res = { ignored: [], created: [], resent: [], error: [] }
    orgs_course = OrgsCourse.by_org(org).by_course(course).first
    raise 'Org is not enrolled to Course' unless orgs_course

    user_ids.each do |user_id|
      user = org.users.find_by_id(user_id)
      create_reminders_for_user(orgs_course, user, res)
    end

    res
  end

  def self.create_reminders_for_all_users(org, course, manager = nil)
    res = { ignored: [], created: [], resent: [], error: [] }
    orgs_course = OrgsCourse.by_org(org).by_course(course).first
    raise 'Org is not enrolled to Course' unless orgs_course

    org.users.each do |user|
      if course.users.include?(user)
        create_reminders_for_user(orgs_course, user, res)
      end
    end

    # Send statistics
    if manager
      res_emails = {}
      res.each do |group, user_ids|
        res_emails[group] = user_ids.map {|user_id| User.find(user_id).email }
      end

      NotificationMailer.mailing_stats(manager, course, 'Create reminders', res_emails).deliver
    end

    res
  end

  def self.create_reminders_for_user(orgs_course, user, res)
    if orgs_course.course.users.include?(user)
      reminder = orgs_course.reminders.by_user(user).first

      if orgs_course.course.is_course_completed?(user) || !user.token_authenticatable?
        res[:ignored] << user.id

        if reminder
          reminder.complete_reminder
        end

        return
      end

      if reminder
        reminder.reset_reminder
        res[:resent] << user.id
      else
        reminder = orgs_course.reminders.by_user(user).create
        res[:created] << user.id
      end

      Delayed::Job.enqueue ReminderJob.new(reminder.id)
    else
      res[:error] << user.id
    end
  end

  def self.reminder_state_list
    self.state_machines[:reminder_state].states.map do |s|
      s.name.to_s
    end
  end
end
