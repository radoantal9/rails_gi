require 'spec_helper'
require 'views/view_spec_helper'

describe "Student journal", :js => true, :type => :request  do
  include_context "dashboard"

  context 'For newly registered user' do
    it "admin is able to see journal"  do

      # register new student with $unew_email and logout
      register_student
      UserEventsMaterializedView.refresh!

      visit '/logout'

      login_admin

      u = User.where(email: $unew_email).first
      puts "user id: #{u.id}"

      visit "/orgs/#{o1.id}/courses/#{course_a.id}/summary"

      # find(:xpath, "//a[contains(@href,'certificate/#{u.id}')]").click
      visit "/journal/#{u.id}/?debug=1"

      page.should have_text(course_a.title)

      visit "/journal/#{u.id}"

    end


  end


end
