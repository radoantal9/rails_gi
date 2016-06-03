# Snapshot of results for a user
class QuizResult < ActiveRecord::Base
  # Relations
  belongs_to :user
  belongs_to :quiz
  has_many :question_grade_reports, dependent: :destroy, after_add: :write_score, after_remove: :write_score

  # Scopes
  scope :by_user, ->(user) { where(user_id: user) }
  scope :by_quiz, ->(quiz) { where(quiz_id: quiz) }

  # Fields
  attr_accessible :quiz, :user, :score

  # Callbacks
  after_create :write_score

  def read_score
    read_attribute :score
  end

  # Assemble scores for all the question grade reports for this user
  def write_score(obj = nil)
    denominator = self.question_grade_reports.count
    numerator = self.question_grade_reports.sum(:score).to_f
    #puts "Grade reports: #{denominator}, Correct scores: #{numerator}"

    if denominator > 0
      value = ((numerator / denominator) * 100).round
    else
      value = 0
    end

    self.score = value
    if persisted?
      update_column 'score', value
    end

    #puts "QuizResult#write_score #{id} score #{value} for #{denominator} grade reports"
    value
  end

  def self.update_scores
    QuizResult.find_each do |res|
      res.write_score
      res.save!
    end
  end

  def self.clean_admin_result
    User.find_each do |admin|
      next unless admin.is_admin?

      result = QuizResult.where(user_id:admin)
      if result
        result.find_each do |quiz_result|#.delete_all
          if quiz_result.question_grade_reports
            quiz_result.question_grade_reports.delete_all
          end
        end
        result.delete_all
      end
    end
  end

end
