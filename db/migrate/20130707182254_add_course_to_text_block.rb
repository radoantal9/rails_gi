class AddCourseToTextBlock < ActiveRecord::Migration
  def change
    add_column :text_blocks, :course_id, :integer
    add_column :text_blocks, :learning_module_id, :integer
    add_column :text_blocks, :lesson_id, :integer

    add_index :text_blocks, :course_id
    add_index :text_blocks, :learning_module_id
    add_index :text_blocks, :lesson_id
  end
end
