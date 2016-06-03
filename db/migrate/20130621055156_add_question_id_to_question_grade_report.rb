class AddQuestionIdToQuestionGradeReport < ActiveRecord::Migration
  def change
    add_column :question_grade_reports, :question_id, :integer
  end
end
