class Admin::SessionsController < ApplicationController
  def new
    redirect_to admin_root_path if admin_signed_in?
  end

  def create
    admin = Admin.find_by(email: submitted_email)
    if admin&.authenticate(submitted_password)
      target = session.delete(:return_to).presence || admin_root_path
      reset_session
      session[:admin_id] = admin.id
      redirect_to target, notice: "Signed in."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out."
  end

  private

  def submitted_email
    params.dig(:session, :email).to_s.strip.downcase
  end

  def submitted_password
    params.dig(:session, :password).to_s
  end
end
