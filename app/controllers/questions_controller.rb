class QuestionsController < InheritedResources::Base
  load_and_authorize_resource

  # Todo: Show error message if question not found for all POST methods
  # Todo: Assign tab capture to question source code text area

  def privacy
    @org = Org.find(params[:org_id]) if params[:org_id].present?
    @course = Course.find(params[:course_id]).force_course_pages if params[:course_id].present?

    if request.post?
      if params[:privacy_levels]
        params[:privacy_levels].each do |question_id, privacy_level|
          privacy = QuestionPrivacy.by_question(question_id).by_org(@org)
          #privacy = privacy.by_course(@course)
          privacy = privacy.first || privacy.create
          privacy.update_attribute(:question_privacy, privacy_level) if privacy.question_privacy != privacy_level.to_sym
        end
      end

      render :json => {}
      return
    else
      @questions = Question.ungraded_questions.order('id ASC')
    end
  end

  # Must be an admin to edit
  def edit
    @question = Question.find(params[:id])
  end

  def update
    update! { edit_question_path }
  end

  # Index
  def index
    @questions = initialize_grid(Question, 
                                 :per_page => 10, 
                                 :order => 'questions.updated_at', 
                                 :order_direction => 'desc',
                                 :enable_export_to_csv => true,
                                 :name => 'grid',
                                 :csv_field_separator => ',',
                                 :csv_file_name => 'questions')

    export_grid_if_requested('grid' => 'index_grid_csv')
  end

  # Must be an admin
  def show
    @question = Question.find(params[:id])
  end

  # Must be a user of
  # Must be a logged in user to test (doesn't matter active org or not); attempt will be saved
  def test
    @question = Question.find(params[:id])

    #create a quiz object which will hold this question
    #this is only for temporary testing purposes, production
    #use will always require having a proper quiz object and
    #associating this question to that object and having the
    #quiz grade itself
    z = Quiz.new
    z.questions << @question

  end

  # Gets post from the question form, returns JSON with corrections and logs attempt in the DB
  def grade
    @question = Question.find(params[:id])

    #given answer value is a hash of answers
    #given_answer = params[@question.id.to_s].to_s.gsub("\"", "")

    given_answer = params[@question.id.to_s] #.to_s.gsub("\"", "")
    given_comment = params['comment'][@question.id.to_s] if params['comment']

    @question_grade_obj = @question.grade(given_answer, current_user, given_comment)

    # Call the grade method on this object and return the resulting
    # object which will have score and corrections
    @question_grade_obj.save!

    # Create a quiz result to store this question grade report
    # this quiz result will not have any quiz associated to it
    @quiz_result = QuizResult.new
    @quiz_result.user = current_user
    @quiz_result.question_grade_reports << @question_grade_obj

    @quiz_result.save!

    render :json => @question_grade_obj
  end
end
