class CreateUserDetails < ActiveRecord::Migration
  def change
    create_table :user_details do |t|
      t.string :user_photo
      t.integer :user_id
      t.hstore :user_data

      t.timestamps
    end

    add_index :user_details, :user_id
    add_index :user_details, :user_data, using: 'gist'
  end
end
