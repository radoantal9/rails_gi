require 'spec_helper'

describe Org do
  subject do
    create :org
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it 'should scope by_enrollment_code' do
    code1 = create :orgs_course
    code2 = create :orgs_course
    Org.by_enrollment_code(code1.enrollment_code).should include(code1.org)
    Org.by_enrollment_code(code1.enrollment_code).should_not include(code2.org)
  end

  it "has signup_key" do
    subject.signup_key.should_not be_nil
  end

  it 'should return user_managers' do
    u1 = create(:user, :manager)
    u2 = create(:user, :student)
    subject.users << u1
    subject.users << u2

    subject.user_managers.should == [u1]
    #pp subject.user_managers.map(&:email)
  end

  it 'should return students' do
    u1 = create(:user, :manager)
    u2 = create(:user, :student)
    subject.users << u1
    subject.users << u2

    subject.students.should == [u2]
  end

  it '#anonymize_course_data' do
    c1 = create(:course)
    c2 = create(:course)

    create :orgs_course, org: subject, course: c1
    create :orgs_course, org: subject, course: c2

    u1 = create(:user, :manager)
    u2 = create(:user, :student)
    u3 = create(:user, :student)
    subject.users << u1
    subject.users << u2
    subject.users << u3

    c1.users << u1
    c1.users << u2
    c2.users << u3

    subject.users.by_course(c1).should include(u1, u2)
    subject.course_students(c1).should include(u2)
    subject.course_students(c1).should_not include(u3)
    subject.course_students(c1).should_not include(u1)

    subject.course_students(c2).should_not include(u1, u2)
    subject.course_students(c2).should include(u3)

    e1 = u1.email
    e2 = u2.email
    e3 = u3.email
    subject.anonymize_course_data(c1)
    u1.reload
    u2.reload
    u3.reload

    u1.email.should == e1
    u2.email.should_not == e2
    u3.email.should == e3
  end

end
