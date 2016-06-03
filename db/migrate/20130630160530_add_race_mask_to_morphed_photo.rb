class AddRaceMaskToMorphedPhoto < ActiveRecord::Migration
  def change
    add_column :morphed_photos, :race_mask, :string

    add_index :morphed_photos, :race_mask
  end
end
