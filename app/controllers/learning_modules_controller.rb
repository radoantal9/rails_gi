class LearningModulesController < InheritedResources::Base
  load_and_authorize_resource

  def index
    @learning_modules = LearningModule.order('id ASC')
  end

  def update
    begin
      update! { edit_resource_url(resource) }
    rescue => ex
      resource.errors[:base] << ex.message
      render 'edit'
    end
  end

  def sort
    @learning_module.sort_lessons(params[:lesson])

    render nothing: true
  end
end
