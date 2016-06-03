shared_context "dashboard" do

  let!(:o1) {create(:org)}
  let!(:o2) {create(:org)}

  let!(:course_a) {create(:course ,:with_simple_module, title: "Course AA")}
  let!(:course_b) {create(:course ,:with_simple_module, title: "Course BB")}
  let!(:course_c) {create(:course ,:with_simple_module, title: "Course CC")}

  # Pre associated users
  let!(:u2) {FactoryGirl.create(:user, org: o2)}

  let!(:u1) {FactoryGirl.create(:user, :student, org: o1)}
  let!(:u3) {FactoryGirl.create(:user, :student, org: o1)}
  let!(:u4) {FactoryGirl.create(:user, :student, org: o1)}

  # org1 has course A and B but not C
  let!(:oc1a)  {FactoryGirl.create(:orgs_course, org: o1, course: course_a)}
  let!(:oc1b)  {FactoryGirl.create(:orgs_course, org: o1, course: course_b)}

  let!(:inv_org1_course_a)   {FactoryGirl.create(:invitation, orgs_course: oc1a)}
  let!(:inv_org1_course_b)   {FactoryGirl.create(:invitation, orgs_course: oc1b)}

  let!(:oc2a)  {FactoryGirl.create(:orgs_course, org: o2, course: course_a)}
  let!(:inv_org2_course_a)   {FactoryGirl.create(:invitation, orgs_course: oc2a)}

  let!(:user_course_u3_a) {create(:users_course, user: u3, course: course_a)}

  let!(:m1)         {FactoryGirl.create(:user, :manager, org: o1)}
  let!(:admin_user) {FactoryGirl.create(:user, :admin, org: o1)}


  def login_user_manager
    PgSearch::Multisearch.rebuild(User)
    PgSearch::Multisearch.rebuild(Invitation)
    visit '/logout'
    visit '/login'
    fill_in 'user[email]', :with => m1.email
    fill_in 'user[password]', :with => m1.password

    click_button 'Sign in'
    :done_login

  end

  def login_admin
    PgSearch::Multisearch.rebuild(User)
    PgSearch::Multisearch.rebuild(Invitation)
    visit '/logout'
    visit '/login'
    fill_in 'user[email]', :with => admin_user.email
    fill_in 'user[password]', :with => admin_user.password

    click_button 'Sign in'
    :done_login

  end

  def login_user(user)
    PgSearch::Multisearch.rebuild(User)
    PgSearch::Multisearch.rebuild(Invitation)
    visit '/logout'
    visit '/login'
    fill_in 'user[email]', :with => user.email
    fill_in 'user[password]', :with => user.password

    click_button 'Sign in'
    :done_login

  end

  def register_student

    $unew_email = FFaker::Internet.email
    $unew_password = FFaker::Internet.password
    $unew_first_name = FFaker::Name.first_name
    $unew_last_name = FFaker::Name.last_name

    visit '/register_course'

    fill_in 'user_course_code', with: oc1a.enrollment_code
    fill_in 'user[email]', with: $unew_email

    find('#button_check_email_exists').click()

    fill_in 'user_password', with: $unew_password
    fill_in 'user_password_confirmation', with: $unew_password
    click_button 'Sign up'

    expect(page).to have_text("Your Name")

    fill_in "user_first_name", with: $unew_first_name
    fill_in "user_last_name", with: $unew_last_name

    click_button 'Next'

    $current_user = User.find_by_email($unew_email)

    expect(page).to have_text(course_a.title)

  end

  def start_course
    page.find(".btn-dashboard-hero-continue").click
    click_link "Start"
  end

  def start_module
    find("#nextbutton").trigger('click')
  end

  def click_next
    find("#nextbutton").trigger('click')
  end

  def get_percentage_completion
    $course_progress = course_a.user_completion $current_user.id
  end



end
