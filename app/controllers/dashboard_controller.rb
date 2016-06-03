class DashboardController < ApplicationController
  #authorize_resource :class => false
  skip_authorization_check
  before_filter :authenticate_user!

  def show
    @user = current_user

    if current_user
      if current_user.is_admin?
        @user_events = UserEvent.student_activity_events.page(params[:page])
      elsif current_user.is_user_manager? && current_user.org
        @user_events = UserEvent.student_activity_events(current_user.org).page(params[:page])
      end

    end
  end
end
