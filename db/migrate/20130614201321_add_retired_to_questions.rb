class AddRetiredToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :retired, :boolean
  end
end
