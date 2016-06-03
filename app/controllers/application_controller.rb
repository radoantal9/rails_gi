class ApplicationController < ActionController::Base
  protect_from_forgery

  # CanCan
  check_authorization unless: :skip_authorization?
  rescue_from CanCan::AccessDenied, with: :access_denied

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end

  # Called by CanCan
  def access_denied(ex)
    Rails.logger.debug { "Access denied on #{ex.action} #{ex.subject.inspect}" }

    if request.xhr?
      render json: { error: 'Access denied' }, status: :forbidden
    else
      if current_user
        redirect_to dashboard_path, alert: ex.message
      else
        redirect_to authenticate_user!, alert: ex.message
      end
    end
  end

  def skip_authorization?
    # logger.debug self.class
    if devise_controller?
      true
    elsif self.instance_of?(RedactorRails::PicturesController) && can?(:edit, TextBlock)
      true
    else
      false
    end
  end

  def log_error(ex)
    Rails.logger.error ex.inspect
    Rails.logger.error ex.backtrace.join("\n")
  end
end
