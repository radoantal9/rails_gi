class RemoveContentFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :content
    remove_column :question_responses, :content
  end

  def down
    add_column :questions, :content, :text
    add_column :question_responses, :content, :text

    #Question.find_each do |q|
    #  q.update_column :content, q.content
    #end
    #
    #QuestionResponse.find_each do |q|
    #  q.update_column :content, q.content
    #end
  end
end
