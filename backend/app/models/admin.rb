class Admin < ActiveRecord::Base
  MAX_EMAIL_LENGTH = 255

  has_secure_password

  validates :email, presence: true, uniqueness: true, length: { maximum: MAX_EMAIL_LENGTH }
  validates :password_digest, presence: true
end
