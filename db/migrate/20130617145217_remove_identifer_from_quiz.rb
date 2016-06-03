class RemoveIdentiferFromQuiz < ActiveRecord::Migration
  def up
    remove_column :quizzes, :identifier
  end

  def down
    add_column :quizzes, :identifier, :string
  end
end
