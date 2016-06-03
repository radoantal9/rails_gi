require 'spec_helper'
require 'views/view_spec_helper'

describe "Admin", :js => true  do

  include_context "dashboard"

  context 'when user manager is logged in' do
    it "is not on admin dashboard" do
      login_user_manager
      expect(page).to_not have_content("Admin Dashboard")
    end

    it "can only see own org" do
      login_user_manager
      visit "/orgs"
      expect(page).to_not have_content(o2.name)
      page.save_screenshot('tmp/screenshot_user_mgr_own_org.png')
    end

    it "can not create a new org" do
      login_user_manager
      visit "/orgs"
      expect(page).to_not have_content("Create New Org")
      visit "/orgs/new"
      expect(page).to have_content("not authorized")

      page.save_screenshot('tmp/screenshot_user_mgr_create_new_org.png')
    end
  end


  context 'when admin is logged in' do
    it "can create a new org"  do

      login_admin

      expect(page).to have_content("Admin Dashboard")
      find(:xpath, "//div[contains(@class,'panel-body')]/ul/li/a[contains(text(),'Manage Orgs')]").click

      expect(page).to have_content("Organizations")
      click_link "Create New Org"

      fill_in "Name", with: "Acme College"
      find("#org_is_active").trigger('click')
      check "Do not require min-words for essays"
      check "Do not show Pledge of Inclusion modal"

      click_button "Create Org"

      expect(page).to have_content("successfully created")
      expect(page).to have_content("Acme College")

      page.save_screenshot('tmp/screenshot_org_admin.png')

    end

  end

end
