require "rails_helper"

RSpec.describe Order, type: :model do
  it "defaults to in_progress status" do
    expect(build(:order).status).to eq("in_progress")
  end

  it "supports submitted status" do
    expect(build(:order, :submitted).status).to eq("submitted")
  end

  describe "customer_name validation" do
    it "does not require customer_name when status is in_progress" do
      expect(build(:order, status: :in_progress, customer_name: nil)).to be_valid
    end

    it "requires customer_name when status is submitted" do
      expect(build(:order, status: :submitted, customer_name: nil)).not_to be_valid
    end

    it "is valid when submitted with a customer_name" do
      expect(build(:order, status: :submitted, customer_name: "Sam")).to be_valid
    end
  end

  describe "#total" do
    it "calculates total from order items when in_progress" do
      order = create(:order)
      drink_a = create(:drink, name: "Latte", price: 4.00)
      drink_b = create(:drink, name: "Mocha", price: 5.00)
      create(:order_item, order: order, drink: drink_a, quantity: 2)
      create(:order_item, order: order, drink: drink_b, quantity: 1)

      expect(order.total).to eq(13.00)
    end

    it "includes add-on prices" do
      order = create(:order)
      drink = create(:drink, price: 4.00)
      shot = create(:add_on, name: "Extra shot", price: 0.50)
      oat = create(:add_on, name: "Oat milk", price: 0.75)
      item = create(:order_item, order: order, drink: drink, quantity: 1)
      create(:order_item_add_on, order_item: item, add_on: shot)
      create(:order_item_add_on, order_item: item, add_on: oat)

      expect(order.total).to eq(5.25)
    end

    it "returns zero for an empty order" do
      expect(create(:order).total).to eq(0)
    end

    it "snapshots total_price when submitted" do
      order = create(:order)
      drink = create(:drink, price: 4.00)
      create(:order_item, order: order, drink: drink, quantity: 2)

      order.customer_name = "Sam"
      order.status = :submitted
      order.save!

      expect(order.total_price).to eq(8.00)
      expect(order.total).to eq(8.00)
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
