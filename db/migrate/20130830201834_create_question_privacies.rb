class CreateQuestionPrivacies < ActiveRecord::Migration
  def change
    create_table :question_privacies do |t|
      t.references :course
      t.references :org
      t.references :question
      t.integer :question_privacy_cd, default: 0

      t.timestamps
    end
    add_index :question_privacies, :course_id
    add_index :question_privacies, :org_id
    add_index :question_privacies, :question_id
  end
end
