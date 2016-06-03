class Org < ActiveRecord::Base
  # Relations
  has_many :users
  has_many :anonymous_students
  has_many :courses, through: :orgs_courses
  has_many :orgs_courses, dependent: :destroy
  has_many :question_privacies, dependent: :destroy
  has_many :org_mails, class_name: 'CourseMail', as: :mail_object, dependent: :destroy
  has_many :org_resources, dependent: :destroy

  # Scopes
  scope :by_enrollment_code, ->(code) { joins(:orgs_courses).where("LOWER(orgs_courses.enrollment_code) = ?", code.try(:downcase)) }

  # Fields
  attr_accessible :contact, :description, :is_active, :name, :domain, :notes, :signup_key, :notifications, :org_details_attr, :org_mails_attributes
  serialize :org_details, Hash
  accepts_nested_attributes_for :org_mails, allow_destroy: true

  validates :signup_key, presence: true, uniqueness: true

  def user_managers
    users.find_all {|user| user.is_user_manager? }
  end

  def students
    users.find_all {|user| user.is_student? }
  end

  # Update notifications for org managers
  # params - [ {"user_id"=>"30", "activity_report"=>"daily", "signup_notification"=>"realtime", "completion_notification"=>"weekly"} ]
  def notifications=(params)
    params.each do |nt|
      user = User.find nt['user_id']
      if user.is_user_manager?
        nt.delete 'user_id'
        user.update_notifications nt
      end
    end
  end

  # Update org_details
  # {"skip_user_details"=>"0"}
  def org_details_attr=(params)
    [:skip_user_details, :disable_min_words_essay, :skip_pledge_modal].each do |attr|
      org_details[attr] = (params[attr] == '1')
    end
  end

  # Skip the name/race page
  def skip_user_details?
    org_details[:skip_user_details]
  end

  # Do not require min-words for essays
  def disable_min_words_essay?
    !!org_details[:disable_min_words_essay]
  end

  # Do not require min-words for essays
  def skip_pledge_modal?
    org_details[:skip_pledge_modal]
  end

  def course_students(course)
    users.by_course(course).only_students
  end

  def anonymize_course_data(course, user_ids = nil)
    raise 'Bad course' unless courses.include?(course)

    course_students(course).each do |user|
      next if user_ids && !user_ids.include?(user.id)
      user = User.find(user)
      user.anonymize_user_data
    end
  end

end
