# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def access_admin?
    record&.admin?
  end
end
