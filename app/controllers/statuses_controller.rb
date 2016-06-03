class StatusesController < ApplicationController
  skip_before_filter :signed_in_user # or whatever

  #http://robforman.com/how-to-setup-a-public-and-http-version-health-check-while-still-using-global-force_ssl-in-rails-for-elastic-load-balancer/
  def show
    render text: ActiveRecord::Migrator.current_version
  end
end