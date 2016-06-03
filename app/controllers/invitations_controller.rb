class InvitationsController < ApplicationController
  skip_authorization_check only: :track
  load_and_authorize_resource :org, except: :track
  load_and_authorize_resource :course, through: :org, except: :track
  load_and_authorize_resource through: :course, except: [:create, :track]

  def index
    @orgs_course = @org.orgs_courses.by_course(@course).first
    @invitations = Invitation.by_org_course(@orgs_course)

    opts = {
      :per_page => 25,
      :order => 'created_at',
      :order_direction => 'desc',
      :enable_export_to_csv => true,
      :name => 'invitations',
      :csv_field_separator => ',',
      :csv_file_name => 'invitations'
    }
    @invitations_grid = initialize_grid(@invitations, opts)

    export_grid_if_requested
  end

  def show
  end

  def create
    emails = ''
    if params[:emails].present?
      emails << params[:emails]
    end
    if params[:emails_file].present?
      emails << "\n" << params[:emails_file].read
    end
    Rails.logger.info emails

    Invitation.delay.create_invitations(@org, @course, emails, current_user)
    flash[:notice] = "Sending invitations in background"

    # Create users and assign to course
    # u = User.new(email: "this@butlercc.edu", password: "12puppies", password_confirmation: "12puppies", org_id: 15)
    # uc = UsersCourse.new( course_id: 1, user_id: u.id)
    # TODO: Send a email "bulk_user_email_template" with user id, password and a link to start the course
    # scenarios:
    # 1. User doesn't exist (create and send start_course_email with link in it)
    # 2. User exists but not assigned to course (assign course and send start_course_email with link in it)
    # 3. User exists but not same organization (error)
    # 4. User exists and has assigned to course (do nothing, send reminder email)
    # 5. User email doesn't pass validation (error)
    # Generate a CSV file and email to admin

    # res = Invitation.create_invitations(@org, @course, emails)
    # msg = []
    # res.each do |type, emails|
    #   if emails.present?
    #     msg << "#{emails.count} #{type}"
    #   end
    # end
    #
    # if msg.present?
    #   flash[:notice] = "Result: " + msg.join(' ')
    # end

    redirect_to org_course_invitations_path(@org, @course)
  end

  # POST /orgs/:org_id/courses/:course_id/invitations/resend?:email_subject&:email_message
  def resend
    @course = @org.courses.find(params[:course_id])

    Invitation.delay.resend_invitations(@org, @course, current_user, params[:email_subject], params[:email_message])
    flash[:notice] = "Resending invitations in background"

    # res = Invitation.resend_invitations(@org, @course)
    # flash[:notice] = "Result: resend to #{res[:resend].count} emails"

    redirect_to org_course_invitations_path(@org, @course)
  end

  def activate
    if @invitation.can_deactivate_invitation?
      @invitation.deactivate_invitation
      flash[:notice] = "#{@invitation.invitation_email} deactivated"
    elsif @invitation.can_activate_invitation?
      @invitation.activate_invitation
      flash[:notice] = "#{@invitation.invitation_email} activated"
    else
      flash[:notice] = "#{@invitation.invitation_email} not changed"
    end

    redirect_to org_course_invitations_path(@org, @course)
  end

  # GET /invitation/:token
  def track
    inv = Invitation.by_token(params[:token]).first
    inv.try :view_invitation

    send_file Rails.root.join('public', 'track_pixel.png'), type: 'image/png', disposition: 'inline'
  end
end
