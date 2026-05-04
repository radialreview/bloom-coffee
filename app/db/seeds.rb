# Optional: seed a default admin (idempotent). Sample drinks and add-ons are
# created only when those tables are empty.
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

if Drink.none?
  [
    { name: "Drip Coffee", description: "Today's roast, brewed to order.", price: 3.50 },
    { name: "Americano",   description: "Espresso topped with hot water.",  price: 4.00 },
    { name: "Latte",       description: "Espresso with steamed milk.",      price: 5.00 }
  ].each do |attrs|
    Drink.create!(attrs)
  end
  puts "[seeds] Seeded #{Drink.count} sample drinks."
else
  puts "[seeds] Skipped drink seed: drinks already exist."
end

if AddOn.none?
  [
    { name: "Oat milk",    price: 0.75 },
    { name: "Extra shot",  price: 0.50 },
    { name: "Vanilla syrup", price: 0.50 }
  ].each do |attrs|
    AddOn.create!(attrs)
  end
  puts "[seeds] Seeded #{AddOn.count} sample add-ons."
else
  puts "[seeds] Skipped add-on seed: add-ons already exist."
end
