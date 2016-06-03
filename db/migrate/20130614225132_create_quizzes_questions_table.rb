class CreateQuizzesQuestionsTable < ActiveRecord::Migration
  def up
		create_table :quizzes_questions, :id => false do |t|
			t.references	:quiz
			t.references	:question
		end

		add_index :quizzes_questions, [:quiz_id, :question_id]
		add_index :quizzes_questions, :question_id
  end

  def down
		drop_table :quizzes_questions
  end
end
