class RemoveQuestionIdFromQuizzes < ActiveRecord::Migration
  def up
    remove_column :quizzes, :question_id
  end

  def down
    add_column :quizzes, :question_id, :integer
  end
end
