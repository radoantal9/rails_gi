class CreateContentPageElements < ActiveRecord::Migration
  def change
    create_table :content_page_elements do |t|
      t.integer :position
      t.integer :content_page_id
      t.references :element, polymorphic: true

      t.timestamps
    end

    add_index :content_page_elements, :position
    add_index :content_page_elements, :content_page_id
    add_index :content_page_elements, :element_id
    add_index :content_page_elements, :element_type
  end
end
