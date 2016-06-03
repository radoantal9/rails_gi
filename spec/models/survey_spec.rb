require 'spec_helper'

describe Survey do
  subject do
    create :survey
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it '.survey_state_list' do
    Survey.survey_state_list.should be_present
  end

  it '.create_survey' do
    q1 = create :question, content: QuestionXMLSamples::SURVEY

    inv1 = create :invitation
    res = { ignored: [], created: [], resent: [], error: [] }
    Survey.create_survey inv1.orgs_course, q1, inv1.invitation_email, res
    res[:created].should include inv1.invitation_email

    Survey.create_survey inv1.orgs_course, q1, inv1.invitation_email, res
    res[:resent].should include inv1.invitation_email

    s1 = Survey.first
    s1.submit_survey
    Survey.create_survey inv1.orgs_course, q1, inv1.invitation_email, res
    res[:ignored].should include inv1.invitation_email

    Survey.create_survey inv1.orgs_course, q1, 'bad@mail', res
    res[:error].should include 'bad@mail'

    u1 = create :user, :student, org: inv1.orgs_course.org
    u1.courses << inv1.orgs_course.course
    Survey.create_survey inv1.orgs_course, q1, u1.email, res
    res[:created].should include u1.email
    ap res
  end
end
