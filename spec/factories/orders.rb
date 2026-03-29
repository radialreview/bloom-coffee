FactoryBot.define do
  factory :order do
    status { :cart }

    trait :submitted do
      status { :submitted }
      customer_name { "Jordan" }
    end
  end
end
