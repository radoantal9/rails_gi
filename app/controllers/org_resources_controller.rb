class OrgResourcesController < ApplicationController
  load_and_authorize_resource :org
  load_and_authorize_resource through: :org

  respond_to :html

  def index
    @org_resources = @org_resources.order('org_key ASC, course_id')
    respond_with(@org_resources)
  end

  def show
    respond_with(@org_resource)
  end

  def new
    respond_with(@org_resource)
  end

  def edit
  end

  def create
    @org_resource.save!
    redirect_to org_resources_path(@org)
  rescue
    render 'new'
  end

  def update
    @org_resource.update_attributes!(params[:org_resource])
    redirect_to org_resources_path(@org)
  rescue
    render 'edit'
  end

  def destroy
    @org_resource.destroy
    redirect_to org_resources_path(@org)
  end
end
