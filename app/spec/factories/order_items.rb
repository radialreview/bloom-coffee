FactoryBot.define do
  factory :order_item do
    order
    drink
    quantity { 1 }
  end
end
