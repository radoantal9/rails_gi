class AddOrgDetailsToOrg < ActiveRecord::Migration
  def change
    add_column :orgs, :org_details, :text
  end
end
