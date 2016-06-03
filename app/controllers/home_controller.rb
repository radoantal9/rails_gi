class HomeController < ApplicationController

  skip_authorization_check

  def index
    @user = current_user
    if @user
      redirect_to "/dashboard"
    else
      render :layout => "homepage_layout"
    end
  end

  def list_diff
  end

  def verify_certificate
    if params[:id] && !verify_recaptcha
      flash.now[:alert] = "Please enter the Captcha below and click Verify"
      flash.delete :recaptcha_error
      return
    end

    if params[:id]
      # id can be just user id or with a "-" course id
      uid = params[:id].split("-")[0]
      # Make sure uid is a numer now
      if /\d+/=~ uid
        @user = User.find_by_id(uid)
        if @user.nil?
          flash[:alert] = "Certificate not found"
          return redirect_to verify_url
        end
      else
        flash[:alert] = "Certificate not found"
        return redirect_to verify_url
      end

      @course_id_array = []

      # if course id is provided then just use that otherwise
      # make array of all courses user participated in
      if !@user.nil? && params[:id].split("-")[1]
        @course_id_array << params[:id].split("-")[1].to_i
      else
        @course_id_array = @user.courses.map(&:id)
      end
    end
    puts @course_id_array

  end
end
