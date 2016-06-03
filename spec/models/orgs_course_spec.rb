require 'spec_helper'

describe OrgsCourse do
  subject do
    create :orgs_course
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it 'should validates enrollment_code' do
    subject.should be_valid

    subject.enrollment_code = nil
    subject.should_not be_valid
    subject.enrollment_code = ''
    subject.should_not be_valid
  end

  it 'should be unique' do
    o1 = create :org
    c1 = create :course

    code1 = create :orgs_course, org: o1, course: c1
    expect {
      code2 = create :orgs_course, org: o1, course: c1
    }.to raise_error
  end
end
