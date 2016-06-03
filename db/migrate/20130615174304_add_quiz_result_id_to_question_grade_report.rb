class AddQuizResultIdToQuestionGradeReport < ActiveRecord::Migration
  def change
    add_column :question_grade_reports, :quiz_result_id, :integer
  end
end
