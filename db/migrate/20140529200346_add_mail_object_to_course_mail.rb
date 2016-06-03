class AddMailObjectToCourseMail < ActiveRecord::Migration
  def up
    add_column :course_mails, :mail_object_type, :string
    add_column :course_mails, :mail_object_id, :integer
    add_index :course_mails, [:mail_object_type, :mail_object_id]

    CourseMail.find_each do |course_mail|
      if course_mail.course_id
        course_mail.mail_object = Course.find(course_mail.course_id)
      elsif course_mail.orgs_course_id
        course_mail.mail_object = OrgsCourse.find(course_mail.orgs_course_id)
      end

      course_mail.save!
    end

    remove_column :course_mails, :course_id
    remove_column :course_mails, :orgs_course_id
  end

  def down
    add_column :course_mails, :course_id, :integer
    add_column :course_mails, :orgs_course_id, :integer

    CourseMail.find_each do |course_mail|
      if course_mail.mail_object.is_a? Course
        course_mail.course_id = course_mail.mail_object_id
      elsif course_mail.mail_object.is_a? OrgsCourse
        course_mail.orgs_course_id = course_mail.mail_object_id
      end

      course_mail.save!
    end

    remove_column :course_mails, :mail_object_type
    remove_column :course_mails, :mail_object_id
  end
end
