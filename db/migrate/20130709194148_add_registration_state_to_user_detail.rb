class AddRegistrationStateToUserDetail < ActiveRecord::Migration
  def change
    add_column :user_details, :registration_state, :string

    add_index :user_details, :registration_state
  end
end
