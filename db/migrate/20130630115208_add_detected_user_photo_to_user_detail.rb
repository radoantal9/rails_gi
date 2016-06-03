class AddDetectedUserPhotoToUserDetail < ActiveRecord::Migration
  def change
    add_column :user_details, :detected_user_photo, :string
  end
end
