require 'spec_helper'
require 'views/view_spec_helper'

describe "Org User manager", :js => true  do
  include_context "dashboard"
  u_email = 'sample@email.com'
  u_pass = 'passpass'

  context 'when logged in' do
    it "can see newly registered student's user page"  do

      # Register a new user for org 1 course a
      visit "/register_course/?code=#{oc1a.enrollment_code}"

      within ("#new_user") do
        fill_in 'user[email]', :with => u_email
        fill_in 'user[password]', :with => u_pass
        fill_in 'user[password_confirmation]', :with => u_pass
      end
      click_button 'Sign up'

      fill_in 'user[first_name]', :with => "Chuck"
      fill_in 'user[last_name]', :with => "Norris"

      click_button "Next"
      visit '/logout'

      # login as a manager
      login_user_manager
      #pp m1
      #pp user_course_u3_a
      #page.save_screenshot('screenshot01.png')

      user_show_url = "/orgs/#{o1.id}/users/#{u3.id}"
      #p user_show_url
      visit user_show_url
      expect(page).to have_content("Activity stream")
      #page.save_screenshot('screenshot02.png')

    end

  end
end