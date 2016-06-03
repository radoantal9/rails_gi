class UserOmniauthCallbacksController < Devise::OmniauthCallbacksController
  def new
    @user = session[:omniauth_new_user]

    if @user
      if request.post? && params[:course_code].present?
        @user.course_code = params[:course_code]

        if @user.save
          session[:omniauth_new_user] = nil

          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
          #sign_in_and_redirect @user, :event => :authentication
          sign_in @user
          redirect_to name_user_url
        else
          flash.now[:alert] = @user.errors.full_messages.join("\n")
        end
      end
    else
      redirect_to register_student_url
    end
  end

  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"])
    user_action
  end

  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])
    user_action
  end

  private

  def user_action
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      if @user.is_student? && !@user.user_info_full?
        sign_in @user
        redirect_to name_user_url
      else
        sign_in_and_redirect @user, :event => :authentication
      end
    else
      session[:omniauth_new_user] = @user
      render :new
    end
  end
end
