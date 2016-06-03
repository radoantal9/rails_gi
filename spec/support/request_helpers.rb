module RequestHelpers
  def create_logged_in_user
    user = FactoryGirl.create(:user)
    login(user)
    user
  end

  def create_logged_in_admin
    admin = FactoryGirl.create(:user, :admin)
    pp ">> Inside login admin"
    login(admin)
    admin
  end

  def create_logged_in_manager
    manager = FactoryGirl.create(:user, :manager)
    login(manager)
    manager
  end

  def login(user)
    login_as user, scope: :user
  end
end
