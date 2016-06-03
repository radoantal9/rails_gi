class CreateContentStorages < ActiveRecord::Migration
  def change
    create_table :content_storages do |t|
      t.string :content_hash
      t.text :content_data

      t.timestamps
    end

    add_index :content_storages, :content_hash
  end
end
