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

  it "generates a public_token on create" do
    order = create(:order, customer_name: "Jordan")
    expect(order.public_token).to be_a(String)
    expect(order.public_token.length).to be > 10
  end

  it "rejects customer names exceeding 120 characters" do
    order = build(:order, customer_name: "A" * 121)
    expect(order).not_to be_valid
  end

  it "accepts customer names within 120 characters" do
    order = build(:order, customer_name: "A" * 120)
    expect(order).to be_valid
  end
end
