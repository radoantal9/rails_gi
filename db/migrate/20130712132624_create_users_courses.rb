class CreateUsersCourses < ActiveRecord::Migration
  def change
    create_table :users_courses do |t|
      t.references :user
      t.references :course
    end
  end
end
