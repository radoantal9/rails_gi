class AddMaskPhotoToUserDetail < ActiveRecord::Migration
  def change
    add_column :user_details, :mask_photo, :string
  end
end
