FactoryBot.define do
  factory :drink do
    sequence(:name) { |n| "Drink #{n}" }
    description { "A refreshing beverage." }
    price { 4.50 }
  end
end
