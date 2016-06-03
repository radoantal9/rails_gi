class AddEmailToUserEvent < ActiveRecord::Migration
  def change
    add_column :invitations, :sent_count, :integer, default: 0

    add_column :user_events, :email, :string
    add_index :user_events, :email
  end
end
