class SettingsController < ApplicationController
  def show
    if admin_signed_in?
      redirect_to admin_root_path
    else
      redirect_to root_path, alert: "Access denied. Admins only."
    end
  end
end
