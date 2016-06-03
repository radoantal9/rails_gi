class AddContentHashToQuestion < ActiveRecord::Migration
  def up
    # Question
    add_column :questions, :content_hash, :string
    add_index :questions, :content_hash

    #Question.find_each do |q|
    #  content = q.read_attribute(:content)
    #  q.update_attribute :content_hash, ContentStorage.add_content(content)
    #end

    # QuestionResponse
    add_column :question_responses, :content_hash, :string
    add_index :question_responses, :content_hash

    #QuestionResponse.find_each do |q|
    #  content = q.read_attribute(:content)
    #  q.update_attribute :content_hash, ContentStorage.add_content(content)
    #end
  end

  def down
    remove_column :questions, :content_hash
    remove_column :question_responses, :content_hash
  end
end
