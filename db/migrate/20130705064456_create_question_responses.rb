class CreateQuestionResponses < ActiveRecord::Migration
  def change
    create_table :question_responses do |t|
      t.text :given_answer
      t.text :content
      t.integer :user_id

      t.timestamps
    end
  end
end
