# Response for graded question
class QuestionGradeReport < QuestionResponseBase

  # grade report is part of
  belongs_to :quiz_result

  attr_accessible :correct_answer, :details, :given_answer, :score

  validates :question, :correct_answer, :given_answer, presence: true
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
