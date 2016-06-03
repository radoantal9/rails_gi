require 'spec_helper'

describe UsersCourse do
  subject do
    create :users_course
  end

  it 'subject' do
    expect(subject).to be_a described_class
    ap subject
  end

  it "#user can be enrolled in two courses" do
    u1 = create :user, :student
    c1 = create :course
    c2 = create :course

    # The org has two courses
    create :orgs_course, org: u1.org, course: c1
    create :orgs_course, org: u1.org, course: c2

    expect(u1.org.courses.count).to equal(2)

    # now add the user to two courses
    create :users_course, user: u1, course: c1
    create :users_course, user: u1, course: c2

    expect(u1.courses.count).to equal(2)

  end
  it '#users_courses' do
    user = subject.user
    course = subject.course

    expect(user.users_courses).to include subject
    expect(user.courses).to include course

    expect(course.users_courses).to include subject
    expect(course.users).to include user
  end

  it 'validates uniqueness' do
    c1 = create :course
    u1 = create :user, :student
    create :orgs_course, org: u1.org, course: c1

    create :users_course, user: u1, course: c1
    expect {
      create :users_course, user: u1, course: c1
    }.to raise_error
  end

  it '#generate_authentication_token' do
    tok = subject.generate_authentication_token
    expect(tok).to be_present
    ap tok
  end
end
