class CreateOrgs < ActiveRecord::Migration
  def change
    create_table :orgs do |t|
      t.string :name
      t.string :description
      t.boolean :is_active
      t.text :contact
      t.text :notes
			t.integer :user_id
      t.timestamps
    end
  end
end
