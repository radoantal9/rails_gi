#TODO write spec for create and update

class QuestionResponsesController < InheritedResources::Base
  load_and_authorize_resource

  has_scope :by_user, as: :user_id

  def survey_report
    if request.post?
      report_name, report_file = QuestionResponse.survey_report(params)
      send_data report_file, :filename => "#{report_name}.zip", :type =>  "application/zip"
    end
  end

  def reports
    query = QuestionResponseBase.joins(user: :org).not_private
    if can? :see_all_users, QuestionResponse
      # All users
    elsif can? :see_org_users, QuestionResponse
      # Org users
      query = query.where('users.org_id = ?', current_user.org_id)
      if query.count < APP_CONFIG['min_anonymous_responses']
        query = nil
      end
    else
      # Self
      query = query.by_user(current_user)
    end

    if query
      @question_responses = initialize_grid(query,
                                            :per_page => 10,
                                            :include => [:user],
                                            :enable_export_to_csv => true,
                                            :name => 'grid',
                                            :csv_field_separator => ',',
                                            :csv_file_name => 'submission_reporting')
      export_grid_if_requested('grid' => 'report_csv')
    else
      @question_responses = nil
    end
  end

  def index
    query = QuestionResponse.joins(user: :org)
    if current_user.is_admin?
      # All users
    elsif can? :see_org_users, QuestionResponse
      # Org users
      query = query.where('users.org_id = ?', current_user.org_id)
      if query.count < APP_CONFIG['min_anonymous_responses']
        query = nil
      end
    else
      # Self
      query = query.by_user(current_user)
    end

    if query
      @question_responses = initialize_grid(query,
                                            :per_page => 10,
                                            :include => [:user],
                                            :enable_export_to_csv => true,
                                            :name => 'grid',
                                            :csv_field_separator => ',',
                                            :csv_file_name => 'question_responses')
      export_grid_if_requested('grid' => 'grid_csv')
    else
      @question_responses = nil
    end
  end

  # POST /question_responses
  # params must have :id_question and :given_answer
  def create
    question_response = QuestionResponse.build_response_essay(current_user, params)

    if question_response.try :save
      render json: { message: "answer saved" }
    else
      render json: { message: "error" }, status: :unprocessable_entity
    end
  end

  # POST /question_responses/guess
  # params must have :id_question, :answer, :item
  def guess
    question_response = QuestionResponse.build_response_guess(current_user, params)
    if question_response.try :save
      # load item
      question = Question.find(params[:id_question])
      item = question.xmlnode.xpath("//question/item[@text='" + params[:item].gsub("'", "\\'") + "']").first

      json = GuessQuestion.response(question, item, params[:answer])
      render json: json
    else
      render json: { message: "error" }, status: :unprocessable_entity
    end
  end

  # POST /question_responses/clean_admin_result
  def clean_admin_result
    QuestionResponse.clean_admin_result
    redirect_to question_responses_path
  end
end
