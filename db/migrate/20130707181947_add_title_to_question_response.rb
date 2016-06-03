class AddTitleToQuestionResponse < ActiveRecord::Migration
  def change
    add_column :question_responses, :title, :string
    add_index :question_responses, :title
  end
end
