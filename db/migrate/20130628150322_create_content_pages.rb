class CreateContentPages < ActiveRecord::Migration
  def change
    create_table :content_pages do |t|
      t.string :name

      t.timestamps
    end
  end
end
