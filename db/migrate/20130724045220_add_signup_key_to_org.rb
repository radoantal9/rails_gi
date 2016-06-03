class AddSignupKeyToOrg < ActiveRecord::Migration
  def change
    add_column :orgs, :signup_key, :string
    add_index  :orgs, :signup_key
  end
end
