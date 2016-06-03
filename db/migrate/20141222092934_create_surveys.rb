class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.references :question, index: true
      t.references :question_response, index: true

      t.references :orgs_course, index: true
      t.references :user, index: true
      t.string :survey_email

      t.string :survey_token
      t.string :survey_state
      t.datetime :sent_at
      t.integer :sent_count, default: 0

      t.timestamps
    end

    add_index :surveys, :survey_token
    add_index :surveys, :survey_email
    add_index :surveys, :survey_state
  end
end
