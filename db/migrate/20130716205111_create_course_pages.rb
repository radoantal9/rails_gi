class CreateCoursePages < ActiveRecord::Migration
  def change
    create_table :course_pages do |t|
      t.integer :course_id
      t.references :page, polymorphic: true
      t.integer :page_num

      t.timestamps
    end

    add_index :course_pages, :course_id
    add_index :course_pages, :page_id
    add_index :course_pages, :page_type
    add_index :course_pages, :page_num

    add_column :courses, :course_pages_changed, :boolean
    add_index :courses, :course_pages_changed
  end
end
