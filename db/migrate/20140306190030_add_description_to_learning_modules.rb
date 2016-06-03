class AddDescriptionToLearningModules < ActiveRecord::Migration
  def change
    add_column :learning_modules, :description, :text
    add_column :learning_modules, :description_image, :string
  end
end
