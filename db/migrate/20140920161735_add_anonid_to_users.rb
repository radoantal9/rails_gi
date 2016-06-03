class AddAnonidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :anonid, :string
    add_index :users, :anonid

    add_column :orgs, :domain, :string
    add_index :orgs, :domain
  end
end
