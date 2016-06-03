require "spec_helper"

describe CourseMailPreview do
  let(:org) { create :org }
  let(:course) { create :course }

  it '#course_enrollment_email' do
    code1 = create :orgs_course, org: org, course: course
    u1 = create :user, :student, org: org
    u1.users_courses.create! course: course

    mail = subject.course_enrollment_email(course, org)
    pp mail
  end
end
