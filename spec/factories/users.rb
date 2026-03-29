FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123456" }
    password_confirmation { "password123456" }
    role { :user }

    trait :admin do
      role { :admin }
    end
  end
end
