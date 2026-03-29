require "rails_helper"

RSpec.describe OrderItem, type: :model do
  it "is valid with valid attributes" do
    expect(build(:order_item)).to be_valid
  end

  it "requires a positive quantity" do
    expect(build(:order_item, quantity: 0)).not_to be_valid
  end

  it "does not allow negative quantity" do
    expect(build(:order_item, quantity: -1)).not_to be_valid
  end

  describe "#unit_price" do
    it "returns base price when no add-ons" do
      drink = create(:drink, base_price: 4.50)
      item = create(:order_item, drink: drink)

      expect(item.unit_price).to eq(4.50)
    end

    it "includes add-on prices" do
      drink = create(:drink, base_price: 4.00)
      add_on_a = create(:add_on, name: "Oat Milk", price: 0.50)
      add_on_b = create(:add_on, name: "Extra Shot", price: 0.75)
      item = create(:order_item, drink: drink)
      create(:order_item_add_on, order_item: item, add_on: add_on_a)
      create(:order_item_add_on, order_item: item, add_on: add_on_b)

      expect(item.unit_price).to eq(5.25)
    end
  end

  describe "#line_total" do
    it "multiplies unit price by quantity" do
      drink = create(:drink, base_price: 4.00)
      add_on = create(:add_on, name: "Oat Milk", price: 0.50)
      item = create(:order_item, drink: drink, quantity: 2)
      create(:order_item_add_on, order_item: item, add_on: add_on)

      expect(item.line_total).to eq(9.00)
    end
  end
end
