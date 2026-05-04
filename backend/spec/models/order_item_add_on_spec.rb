require "spec_helper"

RSpec.describe OrderItemAddOn, type: :model do
  let(:order) { create(:order) }
  let(:drink) { create(:drink) }
  let(:add_on) { create(:add_on) }
  let(:order_item) { OrderItem.create!(order: order, drink: drink, quantity: 1, unit_price: 4.25, line_total: 4.75) }

  it "is valid with required attributes" do
    record = OrderItemAddOn.new(order_item: order_item, add_on: add_on, price: 0.50)
    expect(record).to be_valid
  end

  it "is invalid with negative price" do
    record = OrderItemAddOn.new(order_item: order_item, add_on: add_on, price: -0.50)
    expect(record).not_to be_valid
  end
end
