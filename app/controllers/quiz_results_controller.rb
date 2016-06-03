class QuizResultsController  < InheritedResources::Base
  load_and_authorize_resource

  has_scope :by_user, as: :user_id
  has_scope :by_quiz, as: :quiz_id

  def index
    @quiz_results = apply_scopes(QuizResult).page(params[:page])
  end

  # POST /quiz_results/clean_admin_result
  def clean_admin_result
    QuizResult.clean_admin_result
    redirect_to quiz_results_path
  end
end
