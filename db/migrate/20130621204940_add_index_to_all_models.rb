class AddIndexToAllModels < ActiveRecord::Migration
  def change
		
		rename_column :orgs, :tenant, :tenant_id
		rename_column :question_grade_reports, :tenant, :tenant_id
		rename_column :questions, :tenant, :tenant_id
		rename_column :quiz_results, :tenant, :tenant_id
		rename_column :quizzes, :tenant, :tenant_id
		rename_column :quizzes_questions, :tenant, :tenant_id

		add_index :orgs, :tenant_id
		add_index :question_grade_reports, :tenant_id
		add_index :questions, :tenant_id
		add_index :quiz_results, :tenant_id
		add_index :quizzes, :tenant_id
		add_index :quizzes_questions, :tenant_id
		
		add_index :quizzes_questions, :quiz_id
		add_index :quiz_results, :user_id
		add_index :quiz_results, :quiz_id

		add_index :question_grade_reports, :quiz_result_id
		add_index :question_grade_reports, :question_id

		add_index :orgs, :name
		add_index :orgs, :user_id

  end
end
