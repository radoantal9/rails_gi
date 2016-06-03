class AddCreatedAtToUsersCourse < ActiveRecord::Migration
  def change
    add_column :users_courses, :created_at, :datetime
  end
end
