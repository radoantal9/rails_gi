class AddParentPageNumToCoursePage < ActiveRecord::Migration
  def change
    CoursePage.destroy_all

    add_column :course_pages, :parent_page_num, :integer
    add_index :course_pages, :parent_page_num
  end
end
