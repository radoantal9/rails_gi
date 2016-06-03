class ContentPagesController < InheritedResources::Base
  load_and_authorize_resource

  def index
    @content_pages = initialize_grid(ContentPage, 
                                     :include => [:lessons, :course_pages],
                                     :per_page => 10,
                                     :order => 'content_pages.updated_at', 
                                     :order_direction => 'desc',
                                     :enable_export_to_csv => true,
                                     :name => 'grid',
                                     :csv_field_separator => ',',
                                     :csv_file_name => 'content_pages')

    export_grid_if_requested('grid' => 'grid_csv')
  end

  def create
    create! { edit_resource_url(resource) }
  end

  def update
    begin
      if params[:commit] =~ /Add/i
        count = resource.add_elements(params)
        flash[:notice] = "#{count} elements added"

        redirect_to edit_resource_url(resource)
      else
        update! { edit_resource_url(resource) }
      end
    rescue => ex
      resource.errors[:base] << ex.message
      render 'edit'
    end
  end

  def sort
    resource.sort_elements(params[:content_page_element])
    render nothing: true
  end

  # DELETE "/content_pages/4/remove_element/:pos_id"
  def remove_element
    resource.remove_element(params)
    render nothing: true
  end

end
