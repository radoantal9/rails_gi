class CreateCoursesLearningModules < ActiveRecord::Migration
  def change
    create_table :courses_learning_modules, :id => false do |t|
      t.integer :course_id
      t.integer :learning_module_id
      t.integer :position

    end
  end
end
