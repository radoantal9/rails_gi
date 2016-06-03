class UserEventsController < ApplicationController
  load_and_authorize_resource

  def index
    opts = {
      :name => 'user_events',
      :include => [:user, :course],
      :order => 'id',
      :order_direction => 'desc',
      :enable_export_to_csv => true,
      :csv_field_separator => ',',
    }
    @user_events_grid = initialize_grid(UserEvent.unscoped, opts)

    export_grid_if_requested
  end
end
