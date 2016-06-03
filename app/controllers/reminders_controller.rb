class RemindersController < ApplicationController
  skip_authorization_check only: :track
  load_and_authorize_resource :org, except: :track
  load_and_authorize_resource :course, through: :org, except: :track
  load_and_authorize_resource through: :course, except: [:new, :create, :track]

  def new
    authorize! :create_reminder, @course

    @users = Reminder.filter_users(@org, @course, params)
    @org_course = @course.orgs_courses.by_org(@org).first
    @org_course_email = @org_course.course_mails.with_email_type(:reminder).first

    opts = {
      :per_page => 100,
      :name => 'users',
      :enable_export_to_csv => true,
      :csv_field_separator => ',',
    }
    @users_grid = initialize_grid(@users, opts)

    export_grid_if_requested
  end

  # POST /orgs/1/courses/1/reminders?user_ids="id1,id2..." & email_subject & email_message
  def create
    authorize! :create_reminder, @course

    # Update email
    @org_course = @course.orgs_courses.by_org(@org).first
    CourseMail.update_email(@org_course, params[:email_subject], params[:email_message], :reminder)

    # Reminders
    case params[:send_type]
      when 'selected_users'
        res = Reminder.create_reminders(@org, @course, params[:user_ids].split(','))
      when 'all_users'
        Reminder.delay.create_reminders_for_all_users(@org, @course, current_user)
        flash[:notice] = "Sending reminders in background"
        return

        # res = Reminder.create_reminders_for_all_users(@org, @course)
      else
        raise "Unknown send type"
    end

    msg = []
    res.each do |type, emails|
      if emails.present?
        msg << "#{emails.count} #{type}"
      end
    end

    if msg.present?
      flash[:notice] = "Result: " + msg.join(' ')
    end

  rescue => ex
    log_error(ex)
    flash[:alert] = ex.message
  ensure
    redirect_to org_course_reminders_path(@org, @course)
  end

  def index
    @org_course = @course.orgs_courses.by_org(@org).first
    @reminders = Reminder.by_org_course(@org_course)

    opts = {
      :name => 'reminders',
      :include => :user,
      :enable_export_to_csv => true,
      :csv_field_separator => ',',
    }
    @reminders_grid = initialize_grid(@reminders, opts)

    export_grid_if_requested
  end

  def show
  end

  # GET /track_reminder/:token
  def track
    rem = Reminder.by_token(params[:token]).first
    rem.try :view_reminder

    send_file Rails.root.join('public', 'track_pixel.png'), type: 'image/png', disposition: 'inline'
  end
end
