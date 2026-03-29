class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include CartConcern

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || admin_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to access the admin area."
    redirect_to root_path
  end

  def record_not_found
    flash[:alert] = "The page you were looking for could not be found."
    redirect_to root_path
  end
end
