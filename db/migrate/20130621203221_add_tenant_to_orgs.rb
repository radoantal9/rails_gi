class AddTenantToOrgs < ActiveRecord::Migration
  def change
    add_column :orgs, :tenant, :integer
  end
end
