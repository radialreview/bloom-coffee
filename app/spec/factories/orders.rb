FactoryBot.define do
  factory :order do
    status { :in_progress }

    trait :submitted do
      status { :submitted }
      customer_name { "Sam" }
    end
  end
end
