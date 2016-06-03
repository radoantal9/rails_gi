class QuizzesController < InheritedResources::Base
  load_and_authorize_resource

  def index
    @quiz = Quiz.order('id ASC')
  end

  def sort
    @quiz = Quiz.find_by_id(params[:id])
  end

  def sort_update
    # Positions are held in the quiz question join table
    @quiz_question_join = QuizzesQuestion.where(quiz_id: params[:id])

    params[:question].each_with_index do |id, index|
      @quiz_question_join.where(question_id: id).update_all(position: index+1)
    end

    render nothing: true
  end

  def prev
    @quiz_result = current_user.quiz_results.where(quiz_id: params[:id]).first
  
    self.formats = [:json]

    if @quiz_result
      render :grade
    else
      render json: false
    end
  end

  def grade
    @quiz = Quiz.find_by_id(params[:id])
    @quiz_result = QuizResult.where(quiz_id: params[:id], user_id: current_user.id).first
    
    if @quiz_result == nil
      @quiz_result = @quiz.grade(params, current_user)
      @quiz_result.user = current_user
      @quiz_result.save!
    end


    if request.xhr?
      # Rails will include the layout for JSON responses :/
      render format: 'json', layout: false
    else
      redirect_to request.referer
    end
  end

end
