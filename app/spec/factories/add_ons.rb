FactoryBot.define do
  factory :add_on do
    sequence(:name) { |n| "Add-on #{n}" }
    price { 0.50 }
  end
end
