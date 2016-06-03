class QuestionPrivacy < ActiveRecord::Base
  # Relations
  belongs_to :course
  belongs_to :org
  belongs_to :question

  # Scopes
  scope :by_org, ->(org) { where(org_id: org) }
  scope :by_course, ->(course) { where(course_id: course) }
  scope :by_question, ->(question) { where(question_id: question) }

  # Fields
  as_enum :question_privacy, Question::QUESTION_PRIVACY, slim: false
  attr_accessible :course, :org, :question, :question_privacy

  # Validations
  validates :org, :question, presence: true
  validates :question_privacy, as_enum: true
end
