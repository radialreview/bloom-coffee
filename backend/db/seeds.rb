admin_email = ENV.fetch("ADMIN_EMAIL", "admin@bloom.coffee")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

admin = Admin.find_or_initialize_by(email: admin_email)
if admin.new_record?
  admin.password = admin_password
  admin.password_confirmation = admin_password
  admin.save!
end

if Drink.count.zero?
  Drink.create!(
    [
      { name: "Drip Coffee", description: "House roast brewed fresh.", base_price: 3.25 },
      { name: "Latte", description: "Espresso with steamed milk.", base_price: 4.75 },
    ],
  )
end

if AddOn.count.zero?
  AddOn.create!(
    [
      { name: "Oat Milk", price: 0.5 },
      { name: "Extra Shot", price: 0.75 },
    ],
  )
end
