FactoryBot.define do
  factory :drink do
    sequence(:name) { |n| "Drink #{n}" }
    description { "Sample description" }
    base_price { 4.25 }
  end
end
