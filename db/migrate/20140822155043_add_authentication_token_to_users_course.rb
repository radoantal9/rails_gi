class AddAuthenticationTokenToUsersCourse < ActiveRecord::Migration
  def change
    add_column :users_courses, :authentication_token, :string
    add_index :users_courses, :authentication_token
  end
end
