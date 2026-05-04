require "rails_helper"

RSpec.describe OrderItemAddOn, type: :model do
  it "enforces uniqueness of add_on per order_item" do
    item = create(:order_item)
    add_on = create(:add_on)
    create(:order_item_add_on, order_item: item, add_on: add_on)

    duplicate = build(:order_item_add_on, order_item: item, add_on: add_on)
    expect(duplicate).not_to be_valid
  end
end
