class UsersCoursesController < InheritedResources::Base
  load_and_authorize_resource

  def index
    @users_courses_grid = initialize_grid(UsersCourse,
      :include => [:user, :course]
    )
  end

  def show

  end

end
