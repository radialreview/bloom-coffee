admin_email = ENV.fetch("ADMIN_EMAIL", "admin@bloom.coffee")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

admin = Admin.find_or_initialize_by(email: admin_email)
if admin.new_record?
  admin.password = admin_password
  admin.password_confirmation = admin_password
  admin.save!
end

drink_seed_data = [
  { name: "Drip Coffee", description: "Today's roast, brewed to order.", base_price: 3.50 },
  { name: "Americano", description: "Espresso topped with hot water.", base_price: 4.00 },
  { name: "Latte", description: "Espresso with steamed milk.", base_price: 5.00 },
  { name: "Cappuccino", description: "A classic favorite featuring equal parts espresso, milk, and foam.", base_price: 4.25 },
  { name: "Caramel Macchiato", description: "Freshly steamed milk, espresso, and caramel drizzle.", base_price: 5.45 },
  { name: "Flat White", description: "Micro-foamed milk poured over short espresso shots.", base_price: 4.95 },
  { name: "Cold Brew", description: "Slow-steeped in cool water for 20 hours.", base_price: 4.45 },
  { name: "Nitro Cold Brew", description: "Our signature cold brew infused with nitrogen.", base_price: 5.15 },
  { name: "Vanilla Latte", description: "A smooth latte sweetened with vanilla.", base_price: 5.25 },
  { name: "Honey Cinnamon Latte", description: "Honey syrup with a warm cinnamon finish.", base_price: 5.35 },
  { name: "Mocha", description: "Espresso blended with chocolate and steamed milk.", base_price: 5.30 },
  { name: "Chai Latte", description: "Spiced chai concentrate with steamed milk.", base_price: 4.90 },
]

add_on_seed_data = [
  { name: "Oat Milk", price: 0.70 },
  { name: "Almond Milk", price: 0.70 },
  { name: "Extra Shot", price: 0.85 },
  { name: "Vanilla Syrup", price: 0.55 },
  { name: "Caramel Syrup", price: 0.55 },
  { name: "Hazelnut Syrup", price: 0.55 },
  { name: "Honey", price: 0.40 },
  { name: "Whipped Cream", price: 0.60 },
  { name: "Cold Foam", price: 0.80 },
  { name: "Cinnamon", price: 0.25 },
]

drink_seed_data.each do |attributes|
  drink = Drink.find_or_initialize_by(name: attributes[:name])
  drink.assign_attributes(attributes)
  drink.save! if drink.changed?
end

add_on_seed_data.each do |attributes|
  add_on = AddOn.find_or_initialize_by(name: attributes[:name])
  add_on.assign_attributes(attributes)
  add_on.save! if add_on.changed?
end
