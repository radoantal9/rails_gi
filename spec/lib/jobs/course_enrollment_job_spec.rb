require 'spec_helper'

describe CourseEnrollmentJob do
  let(:course) { create :course }
  let(:user) { create :user, :student }

  subject do
    create :orgs_course, org: user.org, course: course
    create :users_course, user: user, course: course
    CourseEnrollmentJob.new course.id, user.id
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it '#perform' do
    subject.perform
  end
end
