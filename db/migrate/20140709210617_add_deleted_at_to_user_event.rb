class AddDeletedAtToUserEvent < ActiveRecord::Migration
  def change
    add_column :user_events, :deleted_at, :datetime
    add_index :user_events, :deleted_at
  end
end
