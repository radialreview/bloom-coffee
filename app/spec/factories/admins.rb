FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@example.test" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
