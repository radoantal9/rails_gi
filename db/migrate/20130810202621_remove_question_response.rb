class RemoveQuestionResponse < ActiveRecord::Migration
  def change
    drop_table :question_grade_reports
    drop_table :question_responses
  end
end
