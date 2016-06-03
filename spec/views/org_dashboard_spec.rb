require 'spec_helper'
require 'views/view_spec_helper'

describe "Org Dashboard view", :js => true  do
  include_context "dashboard"

  before(:each) do
    UserEventsMaterializedView.refresh!
  end

  context 'when user mgr logs in' do
    it "sees courses for org"  do
      login_user_manager
      page.should have_content(course_a.title)
      page.should have_content(course_b.title)
      page.should_not have_content(course_c.title)
      page.save_screenshot('screenshot01.png')
    end

    it "sees summary for a course" do
      login_user_manager
      find(:xpath, "(//a[contains(text(), 'Summary')])[1]").click
      page.should have_content("Progress Summary for: ")
    end

  end


end
