class AddQuizzesToCoursePage < ActiveRecord::Migration
  def up
    add_column :course_pages, :learning_module_id, :integer
    add_column :course_pages, :lesson_id, :integer
    add_column :course_pages, :content_page_id, :integer
    add_column :course_pages, :quiz_ids_str, :text
    add_column :course_pages, :question_ids_str, :text

    add_index :course_pages, :learning_module_id
    add_index :course_pages, :lesson_id
    add_index :course_pages, :content_page_id

    CoursePage.destroy_all
  end

  def down
    remove_column :course_pages, :learning_module_id, :lesson_id, :content_page_id, :quiz_ids_str, :question_ids_str
  end
end
