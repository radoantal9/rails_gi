class AddTenantIdToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :tenant_id, :integer
  end
end
