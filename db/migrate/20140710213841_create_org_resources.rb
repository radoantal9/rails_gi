class CreateOrgResources < ActiveRecord::Migration
  def change
    create_table :org_resources do |t|
      t.references :org
      t.references :course

      t.string :org_key, null: false
      t.text :org_value

      t.timestamps
    end

    add_index :org_resources, :org_id
    add_index :org_resources, :course_id
    add_index :org_resources, :org_key
  end
end
