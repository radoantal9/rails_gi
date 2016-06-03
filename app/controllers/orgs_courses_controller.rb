class OrgsCoursesController < InheritedResources::Base
  load_and_authorize_resource

  def index
    @orgs_courses = OrgsCourse.order('id ASC')
  end

  def update
    update! { edit_resource_path }
  end

  def update_course_mails
    course_emails = {}
    course_emails[:course_mails_attributes] = params[:orgs_course][:course_mails_attributes]
    @orgs_course.update_attributes(course_emails)

    redirect_to :back
  end
end
