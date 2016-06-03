class AddCroppedUserPhotoToUserDetail < ActiveRecord::Migration
  def change
    add_column :user_details, :cropped_user_photo, :string
  end
end
