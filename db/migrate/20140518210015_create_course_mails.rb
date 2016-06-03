class CreateCourseMails < ActiveRecord::Migration
  def change
    create_table :course_mails do |t|
      t.references :course
      t.references :orgs_course
      t.integer :email_type_cd
      t.string :email_subject
      t.text :email_message

      t.timestamps
    end

    add_index :course_mails, :course_id
    add_index :course_mails, :orgs_course_id
    add_index :course_mails, :email_type_cd
  end
end
