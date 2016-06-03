class TextBlocksController < InheritedResources::Base
  load_and_authorize_resource

  def index
    opts = {
      :order => 'text_blocks.updated_at',
      :order_direction => 'desc',
      :enable_export_to_csv => true,
      :name => 'grid',
      :csv_field_separator => ',',
      :csv_file_name => 'text_blocks' }

    @text_blocks = initialize_grid(TextBlock, opts)

    export_grid_if_requested('grid' => 'grid_csv')
  end

  def create
    create! do
      # Add to content_page
      if @text_block.persisted?
        if params[:content_page_id].present?
          content_page = ContentPage.find params[:content_page_id]
          content_page.add_element(resource)

          # redirect_to
          edit_content_page_url(content_page)
        else
          edit_text_block_path(@text_block)
        end
      end
    end
  end

  def update
    update! { edit_text_block_path(@text_block) }
  end
end
