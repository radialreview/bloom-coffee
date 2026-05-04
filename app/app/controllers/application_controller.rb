class ApplicationController < ActionController::Base
  include CartConcern

  allow_browser versions: :modern

  helper_method :current_admin, :admin_signed_in?

  def current_admin
    return @current_admin if defined?(@current_admin)

    @current_admin = session[:admin_id] && Admin.find_by(id: session[:admin_id])
  end

  def admin_signed_in?
    current_admin.present?
  end

  private

  def require_admin
    return if admin_signed_in?

    session[:return_to] = request.fullpath if request.get? || request.head?
    redirect_to admin_login_path, alert: "Please sign in to continue."
  end
end
