require 'spec_helper'

describe 'Search' do
  let!(:u1) {FactoryGirl.create(:user, :with_simple_course)}
  let!(:u2) {FactoryGirl.create(:user, :with_simple_course)}
  let!(:o1) {create(:org)}

  let!(:oc1) {FactoryGirl.create(:orgs_course, org: o1)}
  let!(:i1) {FactoryGirl.create(:invitation, orgs_course: oc1)}

  let(:o2) {create(:org)}
  let(:m1) {FactoryGirl.create(:user, :manager, org: u1.org)}

  context 'when index not refreshed' do
    it "user not there" do
      # ap PgSearch.multisearch(u1.first_name)
      expect(PgSearch.multisearch(u1.first_name)).to be_empty, "Expected search to be empty with user first name: #{u1.first_name}"
    end

    it "invitation not there" do
      expect(PgSearch.multisearch(i1.invitation_email)).to be_empty, "Expected invitation to be not found: #{i1.invitation_email}"
    end
  end

  context 'when index refreshed' do
    it "user there" do
      PgSearch::Multisearch.rebuild(User)
      ap PgSearch.multisearch(u1.first_name)
      expect(PgSearch.multisearch(u1.first_name)[0].searchable_id).to equal(u1.id), "Expected search to contain: #{u1.id}"

    end

    it "invitation there" do
      PgSearch::Multisearch.rebuild(Invitation)
      ap PgSearch.multisearch(i1.invitation_email)
      expect(PgSearch.multisearch(i1.invitation_email)[0].searchable_id).to equal(i1.id), "Expected to find invitation: #{i1.invitation_email}"
    end

  end
end
