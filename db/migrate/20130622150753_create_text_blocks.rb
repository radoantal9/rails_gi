class CreateTextBlocks < ActiveRecord::Migration
  def change
    create_table :text_blocks do |t|
      t.text :private_title
      t.text :raw_content
      t.text :rendered_content
      t.integer :tenant_id

      t.timestamps
    end
  end
end
