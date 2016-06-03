class AddTitleToLearningModule < ActiveRecord::Migration
  def change
    add_column :learning_modules, :title, :string
  end
end
