class RenameQuizDescriptionPrivate < ActiveRecord::Migration
  def change
    rename_column :quizzes, :description_private, :name
  end
end
