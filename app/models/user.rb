class User < ActiveRecord::Base
  include RoleModel
  include PgSearch

  # Relations
  belongs_to  :org
  has_one     :user_detail, dependent: :destroy

  has_many    :quiz_results, dependent: :destroy
  has_many    :question_grade_reports, through: :quiz_results
  has_many    :question_responses, dependent: :destroy

  has_many    :users_courses, dependent: :destroy
  has_many    :courses, through: :users_courses
  has_many    :user_events, dependent: :destroy
  has_many    :reminders, dependent: :destroy
  has_many    :surveys, dependent: :destroy

  has_one     :accepted_invitation, class_name: 'Invitation', dependent: :nullify

  acts_as_commentable
  has_many :authored_comments, class_name: 'Comment', inverse_of: :author, dependent: :destroy

  # Scopes
  scope :by_org, ->(org) { where(org_id: org) }
  scope :by_course, ->(course) { joins(:courses).where('courses.id' => course) }
  scope :by_email, ->(email) { where(email: email.strip.downcase) } # Devise downcase email
  scope :only_students, -> { where(roles_mask: 2) } # bitmask for 'student' role

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  # Fields
  roles :admin, :student, :user_manager, :content_manager, :photo_editor

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :current_password, :remember_me, :provider, :uid,
                  :first_name, :last_name, :org_id, :course_code, :course_token, :signup_key, :create_anonid,
                  :user_roles, :user_detail_attributes
  accepts_nested_attributes_for :user_detail

  attr_accessor :current_password
  attr_accessor :course_code, :course_token # Assign student org, processed after save
  attr_accessor :signup_key # Assign org
  attr_accessor :create_anonid # Anonymous registration

  # Delegations
  delegate :name, to: :org, prefix: true, allow_nil: true
  delegate :user_info_full?, :require_name?, :registration_complete?, :pledge_of_inclusion_applied?, :pledge_of_inclusion_facebook?,
           to: :user_detail, prefix: false, allow_nil: true
  delegate :gender, :race, :race_map, :multi_race_map, to: :user_detail, prefix: true, allow_nil: true

  # Validations
  validates :first_name, :last_name, presence: true, on: :check_names
  validates :anonid, uniqueness: true, allow_nil: true

  validate do
    if signup_key
      org_us = Org.where(:signup_key => signup_key).first
      if org_us
        self.org = org_us
        unless org_us.is_active
          errors[:base] << 'Your organization is not active'
        end
      else
        errors[:signup_key] << 'is not found'
      end
    end

    if course_code.present?
      course = Course.by_enrollment_code(course_code).first
      org_us = Org.by_enrollment_code(course_code).first
      if course && org_us
        if courses.include?(course)
          errors[:course_code] << 'already enrolled'
          self.course_code = nil
        else
          if org_us.is_active
            self.org ||= org_us
          else
            errors[:course_code] << 'Your organization is not active'
            self.course_code = nil
          end
        end
      else
        errors[:course_code] << 'wrong'
        self.course_code = nil
      end
    elsif course_token.present?
      inv = Invitation.by_token(course_token).first
      if inv && inv.can_accept_invitation?
        self.org ||= inv.orgs_course.org
      else
        errors[:course_token] << 'expired'
        self.course_token = nil
      end
    elsif self.org.nil?
      errors[:base] << "Can't register without invitation"
    end

    if org_id_changed?
      # Disallow org change
      courses.each do |course|
        unless self.org.courses.include? course
          errors[:org] << "not subscribed to all courses"
          break
        end
      end
    end

    # Restrict email address by domain
    if !anonymous? && org && org.domain.present? && email.present?
      unless email.downcase.include? org.domain.downcase
        errors[:email] << "email address must be @#{org.domain.downcase}"
      end
    end
  end

  # Callbacks
  before_validation do
    if create_anonid == '1' && anonid.blank?
      # Anonymous registration
      begin
        self.anonid = sprintf '%03d-%03d', SecureRandom.random_number(1_000), SecureRandom.random_number(1_000)
      end while User.where(:anonid => self.anonid).exists?

      self.email = "#{anonid}@example.com" # pass devise validation
      self.first_name = anonid
      self.last_name = 'getinclusive'
    end
  end

  before_create do
    begin
      self.id = SecureRandom.random_number(1_000_000_000)
    end while User.where(:id => self.id).exists?

    if anonid.present? && org.domain.present?
      self.email = "#{anonid}@#{org.domain}"
      self.last_name = org.domain
    end
  end

  before_save do
    if signup_key.present?
      self.roles << :user_manager
    end

    if self.courses.count != 0 and self.roles.count == 0
      self.roles << :student
    end

    self.user_detail ||= UserDetail.new if is_student?
  end

  after_save do
    if course_code.present?
      # Assign course after user creation
      course = Course.by_enrollment_code(course_code).first
      if course && !courses.include?(course)
        users_courses.create course: course
        unless org
          update_column :org_id, Org.by_enrollment_code(course_code).first.id
        end
      end

      self.course_code = nil
    end

    if course_token.present?
      inv = Invitation.by_token(course_token).first
      if inv && inv.can_accept_invitation?
        course = inv.orgs_course.course
        if course && !courses.include?(course)
          users_courses.create course: course
          unless org
            update_column :org_id, inv.orgs_course.org.id
          end
        end

        inv.invited_user = self
        inv.accept_invitation
        inv.save
      end
      self.course_token = nil
    end
  end

  after_create do |u|
    # Send welcome email to student
    unless anonymous? || Rails.env.test?
      u.send_welcome_email
    end
  end

  # Search
  multisearchable :against => [:first_name, :last_name, :email, :anonid]

  PgSearch.multisearch_options = {
    :using => { :tsearch => {:prefix => true}}
  }

  def active_for_authentication?
    if org
      super && org.is_active
    else
      super
    end
  end

  def inactive_message
    org && org.is_active ? super : "Sign in not allowed. Your organization is not active"
  end

  def name
    "#{first_name} #{last_name}"
  end

  # Titlelize name but preserve hyphens
  def titleize_name
    name.split.map(&:capitalize).join(' ')
  end

  def full_name
    "#{name} <#{email}>"
  end

  def is_admin?
    is? :admin
  end

  def is_student?
    is? :student
  end

  def is_user_manager?
    is? :user_manager
  end

  def is_content_manager?
    is? :content_manager
  end
  
  def password_required?
    new_record? ? false : super
  end

  def anonymous?
    anonid.present?
  end

  # Set roles
  def user_roles
    role_symbols
  end

  def user_roles=(new_roles)
    self.roles = new_roles.map(&:to_sym)
  end

  # Mailers
  def send_welcome_email
    if is_student?
      WelcomeMailer.delay.welcome_student_email(self)
    elsif is_admin?
      WelcomeMailer.delay.welcome_admin_email(self)
    else
      WelcomeMailer.delay.welcome_org_email(self)
    end

    User.delay.send_realtime_notification(:signup_notification, self)
  end

  def student_registration_email
    UserMailer.delay.student_registration_email(self)
  end

  def manager_registration_email
    UserMailer.delay.manager_registration_email(self)
  end

  def course_enrollment_email(course)
    UserMailer.delay.course_enrollment_email(self, course)
  end

  def course_completion_email(course)
    UserMailer.delay.course_completion_email(self, course)

    User.delay.send_realtime_notification(:completion_notification, self, course)
  end

  # Reset student progress and response data
  def reset_progress
    res = {
      user_events: user_events.where(event_type: UserEvent::COURSE_ACTIVITY_EVENTS),
      quiz_results: quiz_results,
      question_responses: question_responses
    }

    res.each do |name, assoc|
      res[name] = assoc.count
      assoc.destroy_all
    end

    res
  end

  # {"activity_report"=>"daily", "signup_notification"=>"daily", "completion_notification"=>"daily"}
  def notifications
    self.user_detail ||= UserDetail.new
    YAML.load(user_detail.notifications) || {}
  rescue
    {}
  end

  # Subscribe / unsubscribe to notifications
  # Periods: none, realtime, daily, weekly or monthly
  # {"activity_report"=>"daily", "activity_report_since"=> Time.now }
  def update_notifications(params)
    user_notifications = notifications

    %w(activity_report signup_notification completion_notification).each do |type|
      report_since = "#{type}_since"
      old_value = user_notifications[type]

      if params[type].present?
        user_notifications[type] = params[type]

        if params[type] == 'none'
          #user_notifications[report_since] = nil

        elsif old_value.blank? || old_value == 'none'
          # Start with activation
          user_notifications[report_since] = Time.now
        end
      end

      if params[report_since].present?
        user_notifications[report_since] = params[report_since]
      end
    end

    self.user_detail ||= UserDetail.new
    user_detail.notifications = YAML.dump(user_notifications)
    user_detail.save!
  end

  # Send notifications to all user managers
  def self.send_notifications(period)
    Rails.logger.info "User.send_notifications #{period}"
    correct_periods = %w(daily weekly monthly)
    period = period.to_s

    unless correct_periods.include? period
      raise "!send_notifications #{period}"
    end

    each_user_manager do |user|
      begin
        user_period = user.notifications

        if user_period['activity_report'] == period
          puts "NotificationMailer.activity_report #{user.email}"
          NotificationMailer.activity_report(user).deliver
        end

        if user_period['signup_notification'] == period || user_period['signup_notification'] == 'realtime'
          mail = NotificationMailer.signup_notification(user) # nil if no signups
          if mail
            puts "NotificationMailer.signup_notification #{user.email}"
            mail.deliver
          end
        end

        if user_period['completion_notification'] == period || user_period['completion_notification'] == 'realtime'
          mail = NotificationMailer.completion_notification(user) # nil if no signups
          if mail
            puts "NotificationMailer.completion_notification #{user.email}"
            mail.deliver
          end
        end
      rescue => ex
        puts ex.message
        Rails.logger.error "-"*77
        Rails.logger.error ex.inspect
        Rails.logger.error ex.backtrace.join("\n")
      end
    end
  end

  # Send realtime notifications
  #   notification_type - signup_notification, completion_notification
  def self.send_realtime_notification(notification_type, student, course = nil)
    Rails.logger.info "User.send_realtime_notification: #{notification_type}"
    if student.org
      each_user_manager(student.org) do |manager|
        if manager.notifications[notification_type.to_s] == 'realtime'
          if notification_type.to_s == 'signup_notification'
            NotificationMailer.delay.signup_notification(manager, student)
          elsif notification_type.to_s == 'completion_notification'
            NotificationMailer.delay.completion_notification(manager, student, course)
          end
        end
      end
    end
  end

  # Valid org managers
  def self.each_user_manager(org = nil)
    all_users = org.try(:users) || User

    all_users.find_each do |user|
      # if (user.is_user_manager? || user.is_admin?) && user.org  && user.email
      if user.is_user_manager? && user.org  && user.email
        yield user
      end
    end
  end

  # OmniAuth Google
  def self.find_for_google_oauth2(auth)
    info = auth.info
    user = User.where(provider: auth.provider, uid: auth.uid).first
    user ||= User.by_email(info["email"]).first

    # New user
    user ||= User.new provider: auth.provider, uid: auth.uid, email: info["email"],
                      first_name: info["first_name"], last_name: info["last_name"]

    user
  end

  # OmniAuth Facebook
  def self.find_for_facebook_oauth(auth)
    info = auth.info
    user = User.where(provider: auth.provider, uid: auth.uid).first

    # New user
    user ||= User.new provider: auth.provider, uid: auth.uid, email: info["email"],
                      first_name: info["first_name"], last_name: info["last_name"]

    user
  end

  # Authentication token
  def generate_authentication_token
    if self.authentication_token.blank?
      begin
        # self.authentication_token = Devise.friendly_token
        self.authentication_token = SecureRandom.base64(64).tr('+/=lIO0', 'pqrsxyz')
      end while User.where(authentication_token: self.authentication_token).exists?

      save
    end

    self.authentication_token
  end

  def self.find_for_token(token = nil)
    if token
      user = User.where(authentication_token: token).first

      if user.try :token_authenticatable?
        user
      end
    end
  end

  # Disable authentication for admin or user manager roles
  def token_authenticatable?
    !is_user_manager? && !is_admin?
  end

  # Clean user ids, email addresses and names
  def anonymize_user_data
    time = Time.now

    begin
      self.first_name = SecureRandom.hex(8)
    end while self.class.exists?(first_name: self.first_name)

    begin
      self.last_name = SecureRandom.hex(8)
    end while self.class.exists?(last_name: self.last_name)

    self.email = "#{first_name}.#{last_name}@www.example.com"
    self.authentication_token = nil

    save!

    # Clean timestamps on all user records
    if user_detail
      user_detail.update_column :created_at, time
      user_detail.update_column :updated_at, time
    end

    quiz_results.each do |qr|
      qr.update_column :created_at, time
      qr.update_column :updated_at, time
    end

    question_grade_reports.each do |qr|
      qr.update_column :created_at, time
      qr.update_column :updated_at, time
    end

    question_responses.each do |qr|
      qr.update_column :created_at, time
      qr.update_column :updated_at, time
    end

    self.update_column :created_at, time
    self.update_column :updated_at, time
  end

  # Lesson rate
  def set_lesson_rate(course, learning_module, lesson, value)
    self.user_detail ||= UserDetail.new

    lesson_rates = MultiJson.load(user_detail.lesson_rates) rescue {}
    lesson_rates[course.id.to_s] ||= {}
    lesson_rates[course.id.to_s][learning_module.id.to_s] ||= {}
    lesson_rates[course.id.to_s][learning_module.id.to_s][lesson.id.to_s] = value

    user_detail.lesson_rates = MultiJson.dump(lesson_rates)
    user_detail.save!
  end

  # Current lesson rate
  def get_lesson_rate(course, learning_module, lesson)
    lesson_rates = MultiJson.load(user_detail.lesson_rates)
    lesson_rates[course.id.to_s][learning_module.id.to_s][lesson.id.to_s] || 0
  rescue
    0
  end

  def last_course_event(course)
    user_events.by_course(course).where(event_type: UserEvent::COURSE_ACTIVITY_EVENTS).first
  end

  # Devise custom authentication
  #
  # tainted_conditions - { :email => email or anonid }
  def self.find_for_authentication(tainted_conditions)
    login = tainted_conditions[:email]
    if login.present?
      login = login.strip.downcase
      User.where('email = ? OR anonid = ?', login, login).first
    end
  end
end
