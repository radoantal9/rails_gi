class AddTenantToQuizzesQuestions < ActiveRecord::Migration
  def change
    add_column :quizzes_questions, :tenant, :integer
  end
end
