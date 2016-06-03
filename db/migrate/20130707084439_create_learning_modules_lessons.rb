class CreateLearningModulesLessons < ActiveRecord::Migration
  def change
    create_table :learning_modules_lessons, :id => false do |t|
      t.integer :learning_module_id
      t.integer :lesson_id
      t.integer :position
    end
  end
end
