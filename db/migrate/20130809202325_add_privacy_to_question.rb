class AddPrivacyToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :question_privacy_cd, :integer, default: 0
    add_index :questions, :question_privacy_cd

    add_column :question_responses, :question_privacy_cd, :integer, default: 0
    add_index :question_responses, :question_privacy_cd
  end
end
