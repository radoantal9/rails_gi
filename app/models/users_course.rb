class UsersCourse < ActiveRecord::Base
  # Relations
  belongs_to :user
  belongs_to :course

  # Scopes
  scope :by_user, ->(user) { where(user_id: user) }
  scope :by_course, ->(course) { where(course_id: course) }
  scope :by_token, ->(token) { where(authentication_token: token) }

  # Fields
  attr_accessible :course_id, :user_id, :course

  # Delegations
  delegate :name, to: :course

  # Validations
  validates :course, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true
  validates :authentication_token, uniqueness: { allow_nil: true }

  validate do
    if user && course
      # Allow user to add only his/her org's subscribed courses
      if user.org && !course.orgs.include?(user.org)
        errors[:course_id] << "not in org's subscribed courses"
      end
    end
  end

  # Authentication token
  def generate_authentication_token
    if self.authentication_token.blank?
      begin
        self.authentication_token = SecureRandom.hex(16)
      end while UsersCourse.where(authentication_token: self.authentication_token).exists?

      save
    end

    self.authentication_token
  end
end
