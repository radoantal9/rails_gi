require 'spec_helper'

describe "Search view", :js => true  do

  let!(:o1) {create(:org)}
  let!(:o2) {create(:org)}

  let!(:u1) {FactoryGirl.create(:user, org: o1)}
  let!(:u2) {FactoryGirl.create(:user, org: o2)}


  let!(:oc1)  {FactoryGirl.create(:orgs_course, org: o1)}
  let!(:i1)   {FactoryGirl.create(:invitation, orgs_course: oc1)}

  let!(:oc2)  {FactoryGirl.create(:orgs_course, org: o2)}
  let!(:i2)   {FactoryGirl.create(:invitation, orgs_course: oc2)}

  let!(:m1) {FactoryGirl.create(:user, :manager, org: u1.org)}

  def login_user_manager
    PgSearch::Multisearch.rebuild(User)
    PgSearch::Multisearch.rebuild(Invitation)
    visit '/logout'
    visit '/login'
    within ("#new_user") do
      fill_in 'user[email]', :with => m1.email
      fill_in 'user[password]', :with => m1.password
    end
    click_button 'Sign in'
    :done_login

  end

  def click_search
    click_button('Search')
  end
  context 'when user mgr searches' do
    it "sees only users for own org" do

      expect(login_user_manager).to be(:done_login)

      # search for user of own org
      fill_in "query", :with => u1.first_name
      click_search

      expect(page).to have_content(u1.email)

      # search for user of other org
      fill_in "query", :with => u2.first_name
      click_search

      expect(page).to_not have_content(u2.email)

    end

    it "sees only invitations for own org" do
      expect(login_user_manager).to be(:done_login)

      ap PgSearch.multisearch(i1.invitation_email)
      ap PgSearch.multisearch(i2.invitation_email)

      # search for user of own org
      fill_in "query", :with => i1.invitation_email
      click_search

      # Make sure page only has the invite for self org and not other orgs
      expect(page).to have_content("Invitation email: #{i1.invitation_email}")
      expect(page).to_not have_content("Invitation email: #{i2.invitation_email}")

      # print "Invitation 1 org:#{PgSearch.multisearch(i1.invitation_email)[0].searchable.orgs_course.org_id}, self org: #{m1.org_id}"

      # search for invitations of other org, this should not return any result
      fill_in "query", :with => i2.invitation_email
      click_search

      expect(page).to_not have_content("Invitation email: #{i2.invitation_email}")

      # page.save_screenshot('screenshot02.png')

    end
  end

end
