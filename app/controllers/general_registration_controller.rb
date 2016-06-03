class GeneralRegistrationController < Devise::RegistrationsController
  skip_authorization_check

  before_action do
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :password, :password_confirmation, :signup_key
    end
  end

  def create
    build_resource(sign_up_params)

    if resource.save
      # Registration email to Admin
      resource.manager_registration_email

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        # respond_with resource, :location => after_sign_up_path_for(resource)
        redirect_to dashboard_url
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        # respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        redirect_to dashboard_url
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
end
