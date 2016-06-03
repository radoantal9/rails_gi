class SearchController < ApplicationController 
  load_and_authorize_resource :class => false

  def index
    @query = params[:query]
    @user = current_user

    if @user.is_admin?
      @results = PgSearch.multisearch(params[:query])#.page(params[:page])

    elsif @user.is_user_manager?
      # Search users then restrict to those of user org
      @results = PgSearch.multisearch(params[:query]).where(:searchable_type => "User").select {|s| s.searchable.org_id == @user.org_id}
      @results.concat PgSearch.multisearch(params[:query]).where(:searchable_type => "Invitation").select {|s| s.searchable.orgs_course.org_id == @user.org_id}

    elsif @user.is_content_manager?
      courses = Course.by_org(@user.org)
      only_search = {'TextBlock'=>[], 'Question'=>[]}

      courses.each do |course|
        course.learning_modules.each do |s_module|
          s_module.lessons.each do |lesson|
            lesson.content_pages.each do |content_page|

              only_search['TextBlock'] += content_page.text_blocks.pluck(:id)

              qu_ids = content_page.quizzes.map do |quiz| 
                quiz.questions.pluck(:id)
              end
              qu_ids.flatten!
              only_search['Question'] += qu_ids

              un_qu_ids = content_page.ungraded_questions.pluck(:id)
              only_search['Question'] += un_qu_ids
            end
          end
        end

      end
      @results_sourse = PgSearch.multisearch(params[:query])

      result_1 = @results_sourse.where(:searchable_type => 'TextBlock',
                      :searchable_id => only_search['TextBlock'])
      result_2 = @results_sourse.where(:searchable_type => 'Question',
                      :searchable_id => only_search['Question'])
      result_2.each do |res|
        result_1 << res
      end

      @results = result_1#.page(params[:page])
    end
  end
end
