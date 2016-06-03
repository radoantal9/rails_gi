class Quiz < ActiveRecord::Base
  include PgSearch

  # Relations
  has_many :quiz_results

  has_many :content_page_elements, as: :element, dependent: :destroy
  has_many :content_pages, through: :content_page_elements

  has_and_belongs_to_many :questions, :join_table => "quizzes_questions"

  # Fields
  attr_accessible :name, :title, :instructions, :question_ids
  accepts_nested_attributes_for :questions

  # Validations
  validates :instructions, presence: true

  # Callbacks
  before_validation do
    if self.title.blank?
      self.title = self.name
    end
  end

  # Search
  multisearchable :against => [:name, :instructions]

  PgSearch.multisearch_options = {
    :using => { :tsearch => {:prefix => true}}
  }

  def grade(params, user = nil)
    # get a json containing all the answers for the questions in the quiz
    # then for each answer, score the appropriate question
    # Return a new quiz result object

    quiz_result = QuizResult.new
    quiz_result.quiz = self

    # Iterate over each question, create a grade report, save it into quiz_result
    questions.each do |q|
      # Note, question IDs in the param Hash have quotes
      given_comment = params['comment']["#{q.id}"] if params['comment']
      question_grade_report = q.grade(params["#{q.id}"], user, given_comment)

      quiz_result.question_grade_reports << question_grade_report
      question_grade_report.save!

      #puts "Question Grade Report: #{question_grade_report.inspect}"
    end

    #puts "INSIDE QUIZ --- Quiz Result: #{quiz_result.inspect}"
    #puts "INSIDE QUIZ --- Quiz Result report objects: #{quiz_result.question_grade_reports.count}"

    quiz_result
  end

  def label
    "Quiz id: " + self.id.to_s + " - " + self.name[0..80]
  end

  def form_label
    "#{id} - #{name}"
  end
end
