class AddOrgCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :org_code, :string
		add_column :users, :first_name, :string
		add_column :users, :last_name, :string
		add_column :users, :is_manager, :boolean
  end
end
