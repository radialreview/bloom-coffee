# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_access

  private

  def authorize_admin_access
    authorize current_user, :access_admin?
  end
end
