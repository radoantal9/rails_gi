class AddStatusEnumToUserDetail < ActiveRecord::Migration
  def change
    add_column :user_details, :main_photo_status_cd, :integer, default: 0
  end
end
