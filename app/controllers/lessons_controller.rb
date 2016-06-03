class LessonsController < InheritedResources::Base
  load_and_authorize_resource

  def index
    @lessons = Lesson.order('id ASC')
  end

  def sort
  end

  def update
    begin
      update! { edit_resource_url(resource) }
    rescue => ex
      resource.errors[:base] << ex.message
      render 'edit'
    end
  end

  def sort_update
    @lesson.sort_content_pages(params[:content_page])

    render nothing: true
  end
end
