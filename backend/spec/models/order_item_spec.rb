require "spec_helper"

RSpec.describe OrderItem, type: :model do
  let(:order) { create(:order) }
  let(:drink) { create(:drink) }

  it "is valid with required attributes" do
    item = OrderItem.new(order: order, drink: drink, quantity: 1, unit_price: 4.25, line_total: 4.25)
    expect(item).to be_valid
  end

  it "is invalid with zero quantity" do
    item = OrderItem.new(order: order, drink: drink, quantity: 0, unit_price: 4.25, line_total: 0)
    expect(item).not_to be_valid
  end

  it "is invalid with quantity exceeding 20" do
    item = OrderItem.new(order: order, drink: drink, quantity: 21, unit_price: 4.25, line_total: 89.25)
    expect(item).not_to be_valid
  end

  it "is invalid with negative unit_price" do
    item = OrderItem.new(order: order, drink: drink, quantity: 1, unit_price: -1, line_total: -1)
    expect(item).not_to be_valid
  end

  it "accesses add-ons through order_item_add_ons" do
    item = OrderItem.create!(order: order, drink: drink, quantity: 1, unit_price: 4.25, line_total: 4.75)
    add_on = create(:add_on)
    item.order_item_add_ons.create!(add_on: add_on, price: add_on.price)

    expect(item.add_ons).to include(add_on)
  end
end
