class CreateLearningModules < ActiveRecord::Migration
  def change
    create_table :learning_modules do |t|
      t.string :name

      t.timestamps
    end
  end
end
