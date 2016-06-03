require 'spec_helper'
require 'rails_helper'

describe "Invitations registration view", :js => true  do

  let!(:o1) {create(:org)}

  let!(:u1) {FactoryGirl.create(:user, org: o1)}

  let!(:oc1)  {FactoryGirl.create(:orgs_course, org: o1)}
  let!(:inv)   {FactoryGirl.create(:invitation, orgs_course: oc1)}

  before(:each) do
    ap inv
    #visit register_course_path(token: inv.invitation_token)
    visit "/register_course/?token=#{inv.invitation_token}"
    Capybara.ignore_hidden_elements = false
  end

  # Invitation creation and sending specs
  pending "New Invitation object is created if one doesn't exist"
  pending "Existing invitation is ignored"
  pending "Unaccepted invitations are resent"
  pending "Accepted invitations are ignored"
  pending "email should have token based url"

  context "registration page with valid token is visited" do
    it "has pre-filled readonly user email" do
      #http://localhost:3000/register_student?token=0da1e18afa4337d7517e03d6bf6af39d

      expect(page).to have_xpath("//input[@id='user_email' and @readonly='readonly']")
      page.save_screenshot('log/screenshot_inv_reg_step1.png')

    end

    it "email should be invited user's" do
      find(:xpath, "//input[@id='user_email' and @readonly='readonly']").text == inv.invitation_email
    end

    it "course code should be hidden" do
      find(:xpath, "//input[@id='user_course_token']").visible? == false
    end

    it "proceed to next screen if password entered" do
      fill_in 'user_password', with: "secretsecret"
      fill_in 'user_password_confirmation', with: "secretsecret"
      click_on 'Sign up'
      page.save_screenshot('screenshot_inv_reg_step2.png')
      expect(page).to have_text('Your Name')
    end
  end

  context "registration page with valid token is visited" do
    pending "should not have pre-filled email"
    pending "should not have course-code filled in"
  end

end

