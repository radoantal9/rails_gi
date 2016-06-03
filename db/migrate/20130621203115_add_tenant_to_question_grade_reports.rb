class AddTenantToQuestionGradeReports < ActiveRecord::Migration
  def change
    add_column :question_grade_reports, :tenant, :integer
  end
end
