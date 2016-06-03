require 'spec_helper'

describe AnonymousStudent do
  subject do
    create :anonymous_student
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it '#org' do
    subject.org.anonymous_students.should include(subject)
  end
end
