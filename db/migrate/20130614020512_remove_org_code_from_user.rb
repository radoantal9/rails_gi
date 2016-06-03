class RemoveOrgCodeFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :org_code
  end

  def down
    add_column :users, :org_code, :string
  end
end
