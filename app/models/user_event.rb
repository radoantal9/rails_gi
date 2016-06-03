class UserEvent < ActiveRecord::Base
  COURSE_ACTIVITY_EVENTS = %w(content_page_begin content_page_end lesson_begin lesson_end learning_module_begin learning_module_end course_begin course_end).freeze

  # Relations
  belongs_to :user
  belongs_to :course
  belongs_to :learning_module
  belongs_to :lesson
  belongs_to :content_page

  # User events are NOT deleted
  # Validations don't work with 'deleted_at'
  # acts_as_paranoid

  # Fields
  attr_accessible :user, :email, :course, :learning_module, :lesson, :content_page, :event_time, :event_type, :event_data

  # Filters
  after_initialize do
    self.event_time ||= DateTime.now
  end

  # Scopes
  default_scope -> { order('event_time DESC, user_events.id DESC') }
  scope :by_user, ->(user) { where(user_id: user) }
  scope :by_email, ->(email) { where(email: email) }
  scope :by_course, ->(course) { where(course_id: course) }
  scope :by_learning_module, ->(learning_module) { where(learning_module_id: learning_module) }
  scope :by_lesson, ->(lesson) { where(lesson_id: lesson) }
  scope :by_content_page, ->(content_page) { where content_page_id: content_page }
  scope :by_event_type, ->(event_type) { where(event_type: event_type) }
  # Validations
  validates :event_time, :event_type, presence: true

  validate do
    if user && course
      errors[:course_id] << 'must belong to user' unless user.courses.include?(course)
    end

    if course && learning_module && !course.learning_modules.include?(learning_module)
      errors[:learning_module_id] << 'must belong to course'
    end

    if learning_module && lesson && !learning_module.lessons.include?(lesson)
      errors[:lesson_id] << 'must belong to learning_module'
    end

    if lesson && content_page && !lesson.content_pages.include?(content_page)
      errors[:content_page_id] << 'must belong to lesson'
    end
  end

  COURSE_EVENT_VALIDATION = { uniqueness: { scope: [:course_id, :learning_module_id, :lesson_id, :content_page_id, :event_type] } }.freeze

  # States
  state_machine :event_type do
    state :content_page_begin, :content_page_end do
      validates :user, presence: true
      validates :user_id, COURSE_EVENT_VALIDATION.dup
      validates :course, :learning_module_id, :lesson_id, :content_page_id, presence: true
    end

    state :lesson_begin, :lesson_end do
      validates :user, presence: true
      validates :user_id, COURSE_EVENT_VALIDATION.dup
      validates :course, :learning_module_id, :lesson_id, presence: true
    end

    state :learning_module_begin, :learning_module_end do
      validates :user, presence: true
      validates :user_id, COURSE_EVENT_VALIDATION.dup
      validates :course, :learning_module_id, presence: true
    end

    state :course_begin, :course_end do
      validates :user, :course, presence: true
      validates :user_id, COURSE_EVENT_VALIDATION.dup
    end

    # Reminder#reminder_state log
    state :reminder_sent, :reminder_viewed, :reminder_accepted do
      validates :user, :course, presence: true
    end

    # Invitation#invitation_state log
    state :invitation_sent, :invitation_viewed, :invitation_accepted, :invitation_deactivated do
      validates :email, :course, presence: true
      # validates :user, presence: true, if: :invitation_accepted?
    end

    state :manager_activity do
      validates :user, :event_data, presence: true
    end
  end

  # Callbacks
  after_validation do
    # Store user email
    self.event_data ||= {}
    event_data['user_email'] = user.try(:email) || email
    event_data_will_change!
  end

  def self.student_activity_events(org = nil)
    all = UserEvent.where(event_type: %w(course_begin course_end learning_module_end))

    if org
      all = all.joins(:user).where('users.org_id' => org)
    end

    all
  end

  def self.create_manager_activity(manager, student, manager_activity)
    UserEvent.create user: manager, event_type: 'manager_activity' do |ev|
      ev.event_data ||= {}
      ev.event_data['student_id'] = student.id
      ev.event_data['student_email'] = student.email
      ev.event_data['action'] = manager_activity
    end
  end

end
