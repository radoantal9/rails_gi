class CreateOrgsCourses < ActiveRecord::Migration
  def change
    create_table :orgs_courses do |t|
      t.references :org
      t.references :course
      t.string :enrollment_code

      t.timestamps
    end
    add_index :orgs_courses, :org_id
    add_index :orgs_courses, :course_id
  end
end
