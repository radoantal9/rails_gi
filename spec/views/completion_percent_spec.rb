require 'spec_helper'
require 'views/view_spec_helper'

describe "When student registers", :js => true  do
  include_context "dashboard"

  context 'and has made some progress in course' do

    before (:each) do
      register_student

      # We set this from the register_student method by finding
      # user.find_by_email
      puts $current_user.email

      start_course
      expect(page).to have_content("Module")
      start_module
      expect(page).to have_content("Lesson")
      click_next

      find_button("Submit Quiz").click
      expect(page).to have_content("You scored")

      click_next
      click_next

      # save_and_open_page

    end
    it "#can see the course registered to and progress on dashboard"  do
      visit "/dashboard"
      expect(page).to have_content(course_a.title)
      expect(page).to_not have_content(course_c.title)
      get_percentage_completion

      puts $current_user.email
      expect($course_progress).to be > 0
      #expect(page).to have_content(@course_progress)
    end

    it "#has progress page showing % complete after starting course" do

      url = "/courses/#{course_a.id}/progress_stats"
      puts url
      visit url
      get_percentage_completion

      expect($course_progress).to be > 0
      #expect(page).to have_content("#{@course_progress}% of the course")

    end

    it "#has progress JSON page after starting course" do

      visit "/courses/#{course_a.id}/progress_stats.json"
      expect(page).to have_content("course_completion_pct")
      get_percentage_completion

      #TODO: Database cleaner ends up deleting the records so the browser doesnt see the user events
      #expect(page).to have_content(@course_progress)

    end

    it "#has a progress bar on content page showing current progress percentage" do
      get_percentage_completion

      expect(page.find(".progress-bar")).to be
      # save_and_open_page
    end

  end


end
