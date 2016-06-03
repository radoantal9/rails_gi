class StudentRegistrationController < Devise::RegistrationsController
  skip_authorization_check

  before_action do
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :password, :password_confirmation, :course_code, :course_token, :create_anonid
    end
  end

  def new
    user_params = build_user_params
    if user_params
      build_resource(user_params)
      resource.password = "12puppies"
      resource.password_confirmation = "12puppies"
      resource.save
      sign_in resource

      # respond_with self.resource
    end
  end

  def check_user_exists
    email = params[:email].downcase
    @user ||= User.find_by_email(email)
    user_course_code = params[:user_course_code]

    if user_course_code
      @course = Course.joins(:orgs_courses).where(orgs_courses: {enrollment_code: user_course_code.upcase}).first
    end

    return_hash = {}

    return_hash[:user_exists] = (@user.email unless @user.nil?) || ''
    return_hash[:course_exists] = (@course.id unless @course.nil?) || ''

    if @course
      return_hash[:user_enrolled] = @course.users.include?(@user)

      target_org = OrgsCourse.where(enrollment_code: user_course_code.upcase).first.org

      if @user
        return_hash[:code_usable] = (target_org.id == @user.org_id)
      end

      return_hash[:allowed_email] = email.include? (target_org.domain || '')

    end

    respond_to do |format|
      format.json {render :json => return_hash.to_json}
    end
  end

  def new_anon
    user_params = build_user_params
    if user_params
      user_params[:create_anonid] = '1'

      build_resource(user_params)
      respond_with self.resource
    end
  end

  def create
    build_resource(sign_up_params)
    resource.roles = [:student]
    resource.user_detail ||= UserDetail.new

    if resource.save
      Invitation.check_enrollment(resource)

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)

        # Send course enrollment email
        resource.courses.each do |course|
          resource.course_enrollment_email(course)
        end

        if resource.anonymous?
          redirect_to anonymous_user_url
        elsif !resource.org.skip_user_details?
          redirect_to name_user_url
        else
          redirect_to dashboard_url
        end

      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        # respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        redirect_to root_url
      end
    else
      if resource.errors[:email].include? 'has already been taken'
        # redirect_to login_path(email: resource.email)
        course_code = params[:user][:course_code]
        resource = User.find_for_database_authentication(email: params[:user][:email])
        puts "invalid_login_attempt" unless resource

        if resource.valid_password?(params[:user][:password])
          sign_in("user", resource)
          course_to_add = Course.joins(:orgs_courses).where(orgs_courses: {enrollment_code: course_code.upcase}).first

          # is user already enrolled in the course?
          if course_to_add.users.include? current_user
            flash[:notice] = "You are already enrolled in the '#{course_to_add.title}' course.  Please find it below."
            redirect_to dashboard_url
            return
          end

          uc = UsersCourse.new( course_id: course_to_add.id, user_id: current_user.id)

          if uc.valid?
            uc.save
            flash[:notice] = "Thank you! the course has been added to your existing account. Please find it below."
          else
            flash[:notice] = "The code you provided '#{course_code}' was not valid... Please verify it and retry"
          end

          #
          redirect_to dashboard_url
        else

          # flash[:error] = "Your login information was incorrect, please try again"
          clean_up_passwords resource
          respond_with resource

        end

      else
        clean_up_passwords resource
        respond_with resource
      end
    end
  end

  private

  def build_user_params
    user_params = {}
    if params[:token].present?
      inv = Invitation.by_token(params[:token]).first
      if inv
        if inv.can_accept_invitation?
          user_params[:email] = inv.invitation_email
          user_params[:course_token] = inv.invitation_token
        else
          flash[:alert] = 'Invitation has already been used'

          if inv.invited_user
            redirect_to login_path(email: inv.invited_user.anonid || inv.invited_user.email)
          else
            redirect_to login_path
          end
          return
        end
      else
        flash.now[:alert] = 'Invitation expired'
      end
    elsif params[:code].present?
      if Course.by_enrollment_code(params[:code]).exists?
        user_params[:course_code] = params[:code]
      else
        flash.now[:alert] = 'Incorrect course code, please click the Question icon (bottom right of the page) to get in touch with us.'
      end
    end

    user_params
  end

end
