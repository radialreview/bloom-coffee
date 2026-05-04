require "spec_helper"

RSpec.describe Order, type: :model do
  it "assigns an order number on create" do
    order = create(:order, customer_name: "Jordan")
    expect(order.order_number).to be >= 1000
  end

  it "increments order number for subsequent orders" do
    first = create(:order, customer_name: "Jordan")
    second = create(:order, customer_name: "Avery")

    expect(second.order_number).to eq(first.order_number + 1)
  end
end
