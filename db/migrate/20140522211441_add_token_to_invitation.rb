class AddTokenToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :invitation_token, :string
    add_column :invitations, :sent_at, :datetime
    add_index :invitations, :invitation_token
    add_index :invitations, :sent_at
  end
end
