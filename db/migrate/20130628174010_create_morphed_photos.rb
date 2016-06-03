class CreateMorphedPhotos < ActiveRecord::Migration
  def change
    create_table :morphed_photos do |t|
      t.string :photo
      t.integer :user_detail_id
      t.string :tags
      t.integer :data_f
      t.integer :data_t

      t.timestamps
    end

    add_index :morphed_photos, :user_detail_id
    add_index :morphed_photos, :tags
  end
end
