class AddQuestionTypeToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :question_type, :string
  end
end
