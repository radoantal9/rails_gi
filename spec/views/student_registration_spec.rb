require 'spec_helper'
require 'views/view_spec_helper'

describe "Student Registration", :js => true do

  include_context "dashboard"

  context "When new user uses register_course_link" do
    # it "is able to register and see the new course if using proper domain" do
    #
    #   u_email = FFaker::Internet.email
    #   u_password = FFaker::Internet.password
    #   u_first_name = FFaker::Name.first_name
    #   u_last_name = FFaker::Name.last_name
    #
    #   o1.domain = u_email.split("@").last
    #
    #   pp o1
    #   pp u_email
    #   pp oc1a
    #
    #   visit '/register_course'
    #
    #   fill_in 'user_course_code', with: oc1a.enrollment_code
    #   fill_in 'user[email]', with: u_email
    #
    #   find_by_id('button_check_email_exists').click()
    #
    #   find(:xpath, "//input[@id='user_password']").to be
    #
    #   fill_in 'user_password', with: u_password
    #   fill_in 'user_password_confirmation', with: u_password
    #   click_button 'Sign up'
    #
    #   expect(page).to have_text("Your Name")
    #
    #   fill_in "user_first_name", with: u_first_name
    #   fill_in "user_last_name", with: u_last_name
    #
    #   click_button 'Next'
    #
    #   expect(page).to have_text(course_a.title)
    #
    #   # register_specific_student(u_email, u_password, u_first_name, u_last_name, oc1a.enrollment_code)
    #
    # end

    pending "sees email invalid if email domain non-compliance"

  end
  context "When existing user uses register_course_link" do

    # it "is able to add the new course" do
    #
    #   o1.domain = u3.email.split("@").last
    #
    #   visit "/register_course?user_course_code=#{oc1b.enrollment_code}"
    #
    #   fill_in 'user[email]', with: u3.email
    #
    #   expect(page).to have_selector("#button_check_email_exists")
    #
    #   # expect(page).to have_selector("#password-fields-for-new-user")
    #   expect(page).to have_selector('#user_password', visible: false)
    #   expect(page).to have_selector('#signup-confirmation-button', visible: false)
    #
    #   find('#button_check_email_exists').click()
    #
    #   page.save_screenshot('log/screenshot_reg.png')
    #
    #   find(page).to have_text('already have an account')
    #
    #   fill_in 'user_password', with: $unew_password
    #   click_button 'Sign Up'
    #
    #   find(page).to have_text "Your Name"
    #
    #   fill_in "user_first_name", with: $unew_first_name
    #   fill_in "user_last_name", with: $unew_last_name
    #
    #   $current_user = User.find_by_email($unew_email)
    #
    #   expect(page).to have_text(c1.title)
    #   expect(page).to have_text(c1.title)
    #
    # end


    it "check_user_exist returns user_enrolled true if the user is already enrolled" do

      pp user_course_u3_a.user
      pp oc1a

      pp "Is user [#{u3.email}] in the course #{course_a.users.include?(u3)} #{course_a.orgs_courses.first.enrollment_code}"

      post_URL = "/check_user_exists.json?email=#{u3.email}&user_course_code=#{oc1a.enrollment_code}"
      pp "checking at #{post_URL}"

      visit post_URL

      expect(page).to have_content('"user_enrolled":true')

    end
  end
end
