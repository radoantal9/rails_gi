class SurveysController < ApplicationController
  skip_authorization_check only: [:track, :show, :submit]
  load_and_authorize_resource :org, except: [:track, :show, :submit]
  load_and_authorize_resource :course, through: :org, except: [:track, :show, :submit]
  load_and_authorize_resource through: :course, except: [:new, :create, :track, :show, :submit]

  def new
    authorize! :create_survey, @course

    @users = Survey.filter_users(@org, @course, params)
    @invitations = Survey.filter_invitations(@org, @course, params)
    @org_course = @course.orgs_courses.by_org(@org).first
    @org_course_email = @org_course.course_mails.with_email_type(:survey).first

    opts = {
      :per_page => 100,
      :name => 'users',
      :enable_export_to_csv => true,
      :csv_field_separator => ',',
    }
    @users_grid = initialize_grid(@users, opts) if @users

    opts = {
      :per_page => 100,
      :name => 'invitations',
      :enable_export_to_csv => true,
      :csv_field_separator => ',',
    }
    @invitations_grid = initialize_grid(@invitations, opts) if @invitations

    if @users_grid || @invitations_grid
      export_grid_if_requested
    end
  end

  # POST /orgs/1/courses/1/surveys?user_ids="id1,id2..." & email_subject & email_message
  def create
    authorize! :create_survey, @course

    # Update email
    @org_course = @course.orgs_courses.by_org(@org).first
    CourseMail.update_email(@org_course, params[:email_subject], params[:email_message], :survey)

    question = Question.by_question_type('survey').find_by_id(params[:question_id])
    unless question
      raise 'Bad survey question'
    end

    # Surveys
    case params[:send_type]
      when 'selected_users'
        res = Survey.create_surveys(@org, @course, question, params[:user_ids].split(','), params[:invitation_ids].split(','))
      when 'all_users'
        # res = Survey.create_surveys_for_all_users(@org, @course, question, params)
        Survey.delay.create_surveys_for_all_users(@org, @course, question, params, current_user)
        flash[:notice] = "Sending surveys in background"
        return
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
    redirect_to org_course_surveys_path(@org, @course)
  end

  def index
    @org_course = @course.orgs_courses.by_org(@org).first
    @surveys = Survey.by_org_course(@org_course)

    opts = {
      :name => 'surveys',
      :include => :user,
      :enable_export_to_csv => true,
      :csv_field_separator => ',',
    }
    @surveys_grid = initialize_grid(@surveys, opts)

    export_grid_if_requested
  end

  def show
    @survey = Survey.by_token(params[:token]).first
    if @survey
      @survey.open_survey
      @question = @survey.question
    else
      redirect_to root_path, alert: 'Survey not found'
    end
  end

  def submit
    @survey = Survey.by_token(params[:token]).first
    if @survey
      question_response = QuestionResponse.build_response_survey(@survey, params)
      if question_response.try :save
        @survey.submit_survey
        @survey.save

        render json: { message: "answer saved" }
      else
        render json: { message: "error" }, status: :unprocessable_entity
      end
    end
  end

  # GET /track_survey/:token
  def track
    survey = Survey.by_token(params[:token]).first
    survey.try :view_survey

    send_file Rails.root.join('public', 'track_pixel.png'), type: 'image/png', disposition: 'inline'
  end
end
