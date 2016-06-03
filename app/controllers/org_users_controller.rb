class OrgUsersController < ApplicationController
  load_and_authorize_resource :org
  load_and_authorize_resource class: User, through: :org, through_association: :users, instance_name: :user, except: [:course_users]

  def index
    opts = {
      :per_page => 100,
      :order => 'last_name',
      :order_direction => 'asc',
      :enable_export_to_csv => true,
      :name => 'users',
      :csv_field_separator => ',',
      :csv_file_name => 'users'
    }
    @users_grid = initialize_grid(User.by_org(@org), opts)

    export_grid_if_requested
  end

  def course_users
    @course = @org.courses.find(params[:course_id])
    @users = @course.users.by_org(@org)

    opts = {
      :per_page => 100,
      :order => 'last_name',
      :order_direction => 'asc',
      :enable_export_to_csv => true,
      :name => 'users',
      :csv_field_separator => ',',
      :csv_file_name => 'users'
    }
    @users_grid = initialize_grid(@users, opts)

    export_grid_if_requested
  end

  def show
    @user_events = UserEvent.unscoped.
      where('user_id = ? OR email = ?', @user, @user.email).
      where(event_type: %w(learning_module_begin learning_module_end course_begin course_end reminder_sent invitation_sent))

    opts = {
      :name => 'user_events',
      :include => [:course, :learning_module],
      :order => 'id',
      :order_direction => 'asc',
      :enable_export_to_csv => false,
      :csv_field_separator => ',',
    }

    @user_events_grid = initialize_grid(@user_events, opts)

    email_status_url = APP_CONFIG['email_status_server'] + "/find.json/?email_to=#{@user.email}&" + APP_CONFIG['email_status_server_token_param']
    begin
      @email_json = JSON.load(open(email_status_url))
    rescue Exception => e
      @exception_message = e.inspect
    end

  end

  def reset_progress
    res = @user.reset_progress
    flash[:notice] = "Progress reset: #{res.inspect}"
  rescue => ex
    flash[:alert] = ex.message
  ensure
    redirect_to org_user_path(@org, @user)
  end

  def comment
    Comment.create! commentable: @user, author: current_user, comment_body: params[:comment][:comment_body]
    flash[:notice] = "Comment added"
  rescue => ex
    flash[:alert] = ex.message
  ensure
    redirect_to org_user_path(@org, @user)
  end

  def email
    case params[:email_type]
      when 'reminder'
        count = 0
        @user.courses.each do |course|
          res = Reminder.create_reminders(@org, course, [@user.id])
          count += res[:created].size + res[:resent].size
        end
        flash[:notice] =  "Sent #{count} course reminders to user"

      when 'password'
        @user.send_reset_password_instructions
        flash[:notice] =  "Sent reset password instructions to user"

      else
        raise "Unknown email type: #{params[:email_type]}"
    end

  rescue => ex
    flash[:alert] = ex.message
  ensure
    redirect_to org_user_path(@org, @user)
  end

  def new
  end

  def create
    courses = @org.courses.where(id: params[:course_ids])

    if params[:user][:password].blank? || (params[:user][:password] != params[:user][:password_confirmation])
      raise 'Bad password/confirmation'
    end

    @user.org = @org

    if can? :set_roles, @user
      @user.user_roles = params[:user][:user_roles]
    else
      if courses.empty?
        raise "Enrolled courses can't be empty"
      end
      @user.roles = :student
    end
    @user.courses = courses

    @user.save!

    # Log
    UserEvent.create_manager_activity(current_user, @user, 'created user')

    Invitation.check_enrollment(@user)

    flash[:notice] = 'User was successfully created.'
    redirect_to org_user_path(@org, @user)

  rescue => ex
    flash.now[:alert] = ex.message
    render 'new'
  end

  def edit
    params[:course_ids] = @user.courses.pluck(:id)
  end

  def update
    courses = @org.courses.where(id: params[:course_ids])
    new_password = params[:user][:password]

    if (new_password.present? || params[:user][:password_confirmation].present?) &&
       (new_password != params[:user][:password_confirmation])
      raise 'Bad password/confirmation'
    end

    @user.courses = courses
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.password = new_password if new_password.present?

    if can? :set_roles, @user
      @user.user_roles = params[:user][:user_roles]
    end

    email = params[:user][:email].strip.downcase
    email_old = @user.email
    @user.email = email

    if @user.changed?
      email_changed = @user.email_changed?
      @user.save!

      # Log
      UserEvent.create_manager_activity(current_user, @user, 'updated user')

      # Update email in models
      if email_changed
        Invitation.by_email(email_old).update_all invitation_email: email
        Invitation.check_enrollment(@user)
        UserEvent.by_email(email_old).update_all email: email
      end

      flash[:notice] = "User #{@user.email} was successfully updated."
    end

    redirect_to org_users_path(@org)

  rescue => ex
    flash.now[:alert] = ex.message
    render 'edit'
  end

  def destroy
    @user.destroy

    # Log
    UserEvent.create_manager_activity(current_user, @user, 'deleted user')

    flash[:notice] = "User #{@user.email} was successfully deleted."
    redirect_to org_users_path(@org)
  end

end
