class CreateQuestionGradeReports < ActiveRecord::Migration
  def change
    create_table :question_grade_reports do |t|
      t.float :score
      t.text :given_answer
      t.text :correct_answer
      t.text :content
      t.text :details

      t.timestamps
    end
  end
end
