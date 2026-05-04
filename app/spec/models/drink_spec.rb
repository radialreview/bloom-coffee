require "rails_helper"

RSpec.describe Drink, type: :model do
  describe "validations" do
    it "is valid with name and price" do
      drink = build(:drink, name: "Latte", description: "Espresso and milk", price: 4.25)
      expect(drink).to be_valid
    end

    it "requires a name" do
      drink = build(:drink, name: "")
      expect(drink).not_to be_valid
      expect(drink.errors[:name]).to include("can't be blank")
    end

    it "requires a price" do
      drink = build(:drink, price: nil)
      expect(drink).not_to be_valid
      expect(drink.errors[:price]).to include("can't be blank")
    end

    it "rejects a negative price" do
      drink = build(:drink, price: -0.01)
      expect(drink).not_to be_valid
      expect(drink.errors[:price]).to include("must be greater than or equal to 0")
    end

    it "rejects duplicate names ignoring case" do
      create(:drink, name: "Latte")
      dup = build(:drink, name: "latte")
      expect(dup).not_to be_valid
      expect(dup.errors[:name]).to include("has already been taken")
    end
  end
end
