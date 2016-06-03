class AddParentPageNumsToCoursePages < ActiveRecord::Migration
  def change
    add_column :course_pages, :learning_module_page_num, :integer
    add_column :course_pages, :lesson_page_num, :integer
    add_column :course_pages, :content_page_num, :integer

    add_index :course_pages, :learning_module_page_num
    add_index :course_pages, :lesson_page_num
    add_index :course_pages, :content_page_num

    Course.find_each {|c| c.set_course_pages_changed(true) }
  end
end
