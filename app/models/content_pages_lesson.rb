require_dependency 'course_quiz_validator'

class ContentPagesLesson < ActiveRecord::Base
  # Relations
  belongs_to :lesson
  belongs_to :content_page

  acts_as_list scope: :lesson

  # Validations
  validates :content_page, :lesson, presence: true
  validates_with CourseQuizValidator

  # Fields
  attr_accessible :content_page_id, :lesson_id, :position

  # Default position
  #before_validation do
  #  unless position
  #    self.position = ContentPagesLesson.where(lesson_id: lesson_id).count + 1
  #  end
  #end
end
