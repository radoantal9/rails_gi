class AddPositionToQuizzesQuestions < ActiveRecord::Migration
  def change
    add_column :quizzes_questions, :position, :integer
  end
end
