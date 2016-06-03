require 'spec_helper'

describe UserMailer do
  describe 'org_course_email' do
    let(:org) { create :org }
    let(:course) { create :course }
    let!(:orgs_course) { create :orgs_course, course: course, org: org }
    let(:student) { s = create :user, :student, org: org; s.courses << course; s }

    let!(:course_mail) { create :course_mail, mail_object: course, email_type: :enrollment }
    let!(:org_course_email) { create :course_mail, mail_object: orgs_course, email_type: :enrollment }

    let(:mail) { UserMailer.org_course_email(student, course, 'enrollment') }

    it 'renders the headers' do
      mail.subject.should be_present
      mail.to.should include student.email
      mail.from.should be_present
    end

    it 'renders the body' do
      body = mail.body.encoded
      pp body
      body.should be_present

      body.should include course.title
      body.should include course_mail.email_message
      body.should include org_course_email.email_message
    end
  end

  describe 'survey_email' do
    let(:survey) { create :survey }
    let(:mail) { UserMailer.survey_email(survey) }

    it 'renders the headers' do
      mail.subject.should be_present
      mail.to.should include survey.survey_email
    end

    it 'renders the body' do
      body = mail.body.encoded
      puts body
      body.should be_present
    end
  end
end
