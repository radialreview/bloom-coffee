require "rails_helper"

RSpec.describe Order, type: :model do
  it "defaults to cart status" do
    expect(build(:order).status).to eq("cart")
  end

  it "supports submitted status" do
    expect(build(:order, :submitted).status).to eq("submitted")
  end

  describe "customer_name validation" do
    it "does not require customer_name when status is cart" do
      expect(build(:order, status: :cart, customer_name: nil)).to be_valid
    end

    it "requires customer_name when status is submitted" do
      expect(build(:order, status: :submitted, customer_name: nil)).not_to be_valid
    end

    it "is valid when submitted with a customer_name" do
      expect(build(:order, status: :submitted, customer_name: "Jordan")).to be_valid
    end
  end

  describe "#total" do
    it "sums all order item line totals" do
      order = create(:order)
      drink_a = create(:drink, name: "Latte", base_price: 4.00)
      drink_b = create(:drink, name: "Mocha", base_price: 5.00)
      create(:order_item, order: order, drink: drink_a, quantity: 2)
      create(:order_item, order: order, drink: drink_b, quantity: 1)

      expect(order.total).to eq(13.00)
    end

    it "counts a drink base price once with multiple add-ons" do
      order = create(:order)
      drink = create(:drink, name: "Latte", base_price: 4.00)
      add_on_a = create(:add_on, name: "Oat Milk", price: 0.50)
      add_on_b = create(:add_on, name: "Extra Shot", price: 0.75)
      item = create(:order_item, order: order, drink: drink, quantity: 1)
      create(:order_item_add_on, order_item: item, add_on: add_on_a)
      create(:order_item_add_on, order_item: item, add_on: add_on_b)

      expect(order.total).to eq(5.25)
    end

    it "returns zero for an empty order" do
      expect(create(:order).total).to eq(0)
    end
  end

  describe "#item_count" do
    it "sums quantities across items" do
      order = create(:order)
      create(:order_item, order: order, quantity: 2)
      create(:order_item, order: order, quantity: 3)

      expect(order.item_count).to eq(5)
    end
  end

  describe "#order_number" do
    it "returns a formatted string with the ID" do
      order = create(:order)
      expect(order.order_number).to eq("##{order.id}")
    end
  end
end
