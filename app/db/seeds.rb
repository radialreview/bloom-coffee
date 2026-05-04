# Optional: seed a default admin (idempotent).
#
#   ADMIN_EMAIL=admin@bloomcoffee.test ADMIN_PASSWORD=changeme123 bin/rails db:seed
#
email = ENV["ADMIN_EMAIL"].to_s.strip.presence
password = ENV["ADMIN_PASSWORD"].to_s.presence

if email.blank? || password.blank?
  warn "[seeds] Skipped admin seed: set ADMIN_EMAIL and ADMIN_PASSWORD to seed an admin."
else
  admin = Admin.find_or_initialize_by(email: email)
  admin.password = password
  admin.password_confirmation = password
  admin.save!
  puts "[seeds] Ensured admin user '#{admin.email}'."
end
