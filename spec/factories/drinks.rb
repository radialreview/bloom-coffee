FactoryBot.define do
  factory :drink do
    sequence(:name) { |n| "Drink #{n}" }
    description { "A tasty beverage" }
    base_price { 4.50 }
  end
end
