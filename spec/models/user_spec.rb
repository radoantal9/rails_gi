require 'spec_helper'

describe User do
  subject do
    FactoryGirl.create(:user, :student)
  end

  it "subject" do
    subject.should be_a described_class
    ap subject
  end

  it "should create with random id" do
    u1 = create(:user)
    u2 = create(:user)
    u3 = create(:user)

    pp u1.id, u2.id, u3.id

    (u2.id - u1.id).should_not == (u3.id - u2.id)
  end

  it "should create admin user" do
    FactoryGirl.create(:user, :admin).is_admin?.should be_true
  end

  it "should_not assign bad course_code" do
    subject.course_code = 'xxxxxx'
    expect {
      subject.save!
    }.to raise_error /course code/i
  end

  it "should assign org by course_code" do
    org1 = create :org

    course1 = create :course
    code1 = create :orgs_course, org: org1, course: course1
    course2 = create :course
    code2 = create :orgs_course, org: org1, course: course2

    # student.course_code = code1.enrollment_code
    student = build :user, :student, org: nil, course_code: code1.enrollment_code
    student.should be_valid
    student.save!

    student.reload
    student.org.should == org1
    student.courses.should include course1
    student.courses.should_not include course2

    student.course_code = code2.enrollment_code
    student.save!

    student.reload
    student.courses.should include(course1, course2)
  end

  it 'should create student with course' do
    u1 = FactoryGirl.create(:user, :student, :with_simple_course)
    u1.courses.count.should == 1
  end

  it 'should reset student progress' do
    u1 = FactoryGirl.create(:user, :student, :with_course)
    e = create(:user_event, user: u1, course: u1.courses.first)
    u1.user_events.should_not be_empty
    res = u1.reset_progress
    res[:user_events].should == 1
    u1.user_events.should be_empty
  end

  it 'should set user_roles' do
    subject.is_admin?.should == false
    subject.user_roles = ['admin']
    subject.is_admin?.should == true
  end

  it 'should return notifications' do
    user_manager = FactoryGirl.create(:user, :manager)
    user_manager.notifications.should == {}
  end

  it 'should update_notifications' do
    user_manager = FactoryGirl.create(:user, :manager)
    since = Time.now
    user_manager.update_notifications "activity_report"=>"daily", "activity_report_since"=> since
    pp user_manager.notifications
    user_manager.notifications['activity_report'].should == 'daily'
    user_manager.notifications['activity_report_since'].should == since
  end

  it 'should iterate each_user_manager' do
    o1 = create(:org)
    o2 = create(:org)
    m1 = FactoryGirl.create(:user, :manager, org: o1)
    m2 = FactoryGirl.create(:user, :manager, org: o2)

    User.each_user_manager do |m|
      [m1, m2].should include m
    end

    User.each_user_manager(o1) do |m|
      m1.should == m
    end
  end

  describe "#anonymize_user_data" do
    it 'clear user data' do
      first_name = subject.first_name
      last_name = subject.last_name
      email = subject.email

      subject.anonymize_user_data
      ap subject
      ap subject.user_detail

      subject.first_name.should_not == first_name
      subject.last_name.should_not == last_name
      subject.email.should_not == email
    end

    it 'clear question_responses' do
      time = 1.week.ago

      q1 = create(:question, content: QuestionXMLSamples::SURVEY)
      r1 = create :question_response, user: subject, question: q1, content: q1.content, given_answer: { 1 => 2 }, updated_at: time, created_at: time
      r2 = create :question_response, user: subject, question: q1, content: q1.content, given_answer: { 1 => 2 }, updated_at: time, created_at: time

      subject.anonymize_user_data
      ap subject.question_responses

      subject.question_responses.each do |qr|
        qr.created_at.should_not == time
        qr.updated_at.should_not == time
      end
    end

    it 'clear quiz_results' do
      time = 1.week.ago

      q1 = create(:question, content: QuestionXMLSamples::SINGLE)
      quiz_result = create :quiz_result, user: subject
      r1 = create :question_grade_report, user: subject, quiz_result: quiz_result, question: q1, content: q1.content, updated_at: time, created_at: time
      ap r1

      subject.anonymize_user_data

      subject.question_grade_reports.each do |qr|
        qr.created_at.should_not == time
        qr.updated_at.should_not == time
      end
    end
  end

  it '#set_lesson_rate' do
    u1 = FactoryGirl.create(:user, :student, :with_course)
    c1 = u1.courses.first
    m1 = c1.learning_modules.first
    l1 = m1.lessons.first
    l2 = m1.lessons.all[1]

    u1.get_lesson_rate(c1, m1, l1).should == 0

    u1.set_lesson_rate(c1, m1, l1, 11)
    ap u1.user_detail.user_data

    u1.get_lesson_rate(c1, m1, l1).should == 11
    u1.get_lesson_rate(c1, m1, l2).should == 0

    u1.set_lesson_rate(c1, m1, l2, 22)
    u1.get_lesson_rate(c1, m1, l2).should == 22
  end

  it '#generate_authentication_token' do
    subject.generate_authentication_token.should be_present
    subject.generate_authentication_token.should == subject.generate_authentication_token
  end

  it '#create_anonid' do
    o1 = create :org, domain: 'example.com'
    u1 = create :user, :student, org: o1, create_anonid: '1'
    u1.anonid.length.should be > 6
    u1.email.should == "#{u1.anonid}@#{u1.org.domain}"
  end

  it '#invited_user' do
    inv = create :invitation, invitation_state: :invitation_accepted, invited_user: subject
    subject.destroy
    inv.reload
    ap inv
    inv.should be_persisted
    inv.invited_user.should == nil
  end

  it '.find_for_token' do
    u1 = create :user, :student, authentication_token: 'token1'
    User.find_for_token('token1').should == u1

    [:admin, :user_manager].each do |role|
      u2 = create :user, roles: [role], authentication_token: 'token2'
      User.find_for_token('token2').should == nil
    end
  end
end
