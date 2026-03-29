require "rails_helper"

RSpec.describe OrderItemAddOn, type: :model do
  it "belongs to an order item and an add-on" do
    association = build(:order_item_add_on)
    expect(association).to be_valid
    expect(association.order_item).to be_present
    expect(association.add_on).to be_present
  end

  it "prevents the same add-on from being added twice to one order item" do
    existing = create(:order_item_add_on)
    duplicate = build(:order_item_add_on, order_item: existing.order_item, add_on: existing.add_on)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:add_on_id]).to include("has already been taken")
  end

  it "allows the same add-on on different order items" do
    add_on = create(:add_on)
    first = create(:order_item_add_on, add_on: add_on)
    second = build(:order_item_add_on, add_on: add_on)

    expect(second.order_item).not_to eq(first.order_item)
    expect(second).to be_valid
  end
end
