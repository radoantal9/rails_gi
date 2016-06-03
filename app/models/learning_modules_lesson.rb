class LearningModulesLesson < ActiveRecord::Base
  # Relations
  belongs_to :learning_module
  belongs_to :lesson

  acts_as_list scope: :learning_module

  # Validations
  validates :learning_module, :lesson, presence: true
  validates_with CourseQuizValidator

  # Fields
  attr_accessible :learning_module_id, :lesson_id, :position
end
