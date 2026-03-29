FactoryBot.define do
  factory :add_on do
    sequence(:name) { |n| "Add-On #{n}" }
    price { 0.75 }
  end
end
