class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable

  enum :role, { user: 0, admin: 1 }, default: :user
end
