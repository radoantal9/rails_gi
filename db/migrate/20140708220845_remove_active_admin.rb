class RemoveActiveAdmin < ActiveRecord::Migration
  def change
    # drop_table :active_admin_comments
  rescue => ex
    puts ex.message
  end
end
