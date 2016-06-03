class CreateContentPagesLessons < ActiveRecord::Migration
  def change
    create_table :content_pages_lessons do |t|
      t.integer :position
      t.integer :content_page_id
      t.integer :lesson_id
    end
  end
end
