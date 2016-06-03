require 'spec_helper'

describe CourseMail do
  subject do
    create :course_mail
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it 'validates' do
    cm = build :course_mail, mail_object: nil
    cm.should be_invalid

    cm = build :course_mail, mail_object: create(:org), email_type: :enrollment
    cm.should be_invalid

    cm = build :course_mail, mail_object: create(:course), email_type: :welcome_student
    cm.should be_invalid
  end

  it '.update_email' do
    org_course = create :orgs_course

    cm = CourseMail.update_email(org_course, 'email_subject', 'email_message', :reminder)
    cm.email_subject.should == 'email_subject'
    cm.email_message.should == 'email_message'
    ap cm

    cm2 = CourseMail.update_email(org_course, 'email_subject2', 'email_message2', :reminder)
    cm2.should == cm
    cm.reload
    cm.email_subject.should == 'email_subject2'
    cm.email_message.should == 'email_message2'
  end
end
