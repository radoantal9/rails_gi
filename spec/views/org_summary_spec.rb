require 'spec_helper'

describe "Org Dashboard view", :js => true  do


  let!(:o1) {create(:org)}
  let!(:o2) {create(:org)}

  let!(:course_a) {create(:course ,:with_simple_module, title: "Course AA")}
  let!(:course_b) {create(:course ,:with_simple_module, title: "Course BB")}
  let!(:course_c) {create(:course ,:with_simple_module, title: "Course CC")}

  let!(:u1) {FactoryGirl.create(:user, org: o1)}
  let!(:u2) {FactoryGirl.create(:user, org: o2)}

  # org1 has course A and B but not C
  let!(:oc1a)  {create(:orgs_course, org: o1, course: course_a)}
  let!(:oc1b)  {create(:orgs_course, org: o1, course: course_b)}

  # u1 is enrolled in course A (through org 1)
  let!(:user_course_u1_a) {create(:users_course, user: u1, course: course_a)}
  # u2 is enrolled in course B (through org 2)

  let!(:inv_org1_course_a)   {FactoryGirl.create(:invitation, orgs_course: oc1a)}
  let!(:inv_org1_course_b)   {FactoryGirl.create(:invitation, orgs_course: oc1b)}

  let!(:oc2a)  {FactoryGirl.create(:orgs_course, org: o2, course: course_a)}
  let!(:inv_org2_course_a)   {FactoryGirl.create(:invitation, orgs_course: oc2a)}

  let!(:m1) {FactoryGirl.create(:user, :manager, org: u1.org)}

  def login_user_manager
    PgSearch::Multisearch.rebuild(User)
    PgSearch::Multisearch.rebuild(Invitation)
    UserEventsMaterializedView.refresh!

    visit '/logout'
    visit '/login'
    within ("#new_user") do
      fill_in 'user[email]', :with => m1.email
      fill_in 'user[password]', :with => m1.password
    end
    click_button 'Sign in'
    :done_login

  end

  context 'when user mgr clicks course summary' do
    it "sees summary view"  do
      ap user_course_u1_a

      login_user_manager

      # "//tr[contains(., 'Title IX')]/td/a[contains(.,'Summary')]"
      summary_btn_xpath = "//tr[contains(., '#{course_a.title}')]/td/a[contains(.,'Summary')]"
      ap summary_btn_xpath

      page.find(:xpath, summary_btn_xpath).click

      page.should have_content("participants enrolled in course: 1")
      page.should have_content(u1.email)
      page.should have_content(inv_org1_course_a.invitation_email)

      # user in other org not visible
      page.should_not have_content(u2.email)

      # Journal link should not be visible to managers
      page.should_not have_xpath("//a[contains(., '/journal/')]")

      #find_button('.wg-external-csv-export-button').click
      page.should have_content("Export To CSV")

    end

  end

end
