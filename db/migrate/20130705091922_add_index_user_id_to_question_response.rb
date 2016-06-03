class AddIndexUserIdToQuestionResponse < ActiveRecord::Migration
  def change
    add_index :question_responses, :user_id
  end
end
