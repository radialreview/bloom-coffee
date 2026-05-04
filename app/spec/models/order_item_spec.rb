require "rails_helper"

RSpec.describe OrderItem, type: :model do
  it "requires a positive quantity" do
    expect(build(:order_item, quantity: 0)).not_to be_valid
    expect(build(:order_item, quantity: -1)).not_to be_valid
    expect(build(:order_item, quantity: 1)).to be_valid
  end

  describe "#unit_price" do
    it "returns the drink price when no add-ons" do
      drink = create(:drink, price: 4.50)
      item = create(:order_item, drink: drink)

      expect(item.unit_price).to eq(4.50)
    end

    it "includes add-on prices" do
      drink = create(:drink, price: 4.00)
      item = create(:order_item, drink: drink)
      create(:order_item_add_on, order_item: item, add_on: create(:add_on, name: "Oat milk", price: 0.75))

      expect(item.unit_price).to eq(4.75)
    end
  end

  describe "#line_total" do
    it "multiplies unit_price by quantity" do
      drink = create(:drink, price: 4.00)
      item = create(:order_item, drink: drink, quantity: 3)

      expect(item.line_total).to eq(12.00)
    end
  end
end
