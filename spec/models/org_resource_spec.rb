require 'spec_helper'

describe OrgResource do
  subject do
    create :org_resource
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  describe 'validates' do
    it 'org_key uniqueness' do
      o1 = create :org
      c1 = create :course
      create :orgs_course, org: o1, course: c1

      or1 = create :org_resource, org: o1, course: nil
      expect(build :org_resource, org: o1, org_key: or1.org_key).to be_invalid
      expect(build :org_resource, org: o1, org_key: or1.org_key+'a').to be_valid

      or2 = create :org_resource, org: o1, course: c1
      expect(build :org_resource, org: o1, course: c1, org_key: or2.org_key).to be_invalid
      expect(build :org_resource, org: o1, course: c1, org_key: or2.org_key+'a').to be_valid
    end
  end
end
