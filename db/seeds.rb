# This file should ensure the existence of records required to run the application in every environment (development,
# test). The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@bloomcoffee.com")
admin_password = ENV.fetch("SEED_ADMIN_PASSWORD", "INeedCaffeine!123")

User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = :admin
end
