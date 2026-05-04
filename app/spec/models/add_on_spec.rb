require "rails_helper"

RSpec.describe AddOn, type: :model do
  describe "validations" do
    it "is valid with name and price" do
      expect(build(:add_on, name: "Oat milk", price: 0.5)).to be_valid
    end

    it "requires a name" do
      add_on = build(:add_on, name: "")
      expect(add_on).not_to be_valid
      expect(add_on.errors[:name]).to include("can't be blank")
    end

    it "requires a price" do
      add_on = build(:add_on, price: nil)
      expect(add_on).not_to be_valid
      expect(add_on.errors[:price]).to include("can't be blank")
    end

    it "rejects negative prices" do
      expect(build(:add_on, price: -0.01)).not_to be_valid
    end

    it "accepts zero price" do
      expect(build(:add_on, price: 0)).to be_valid
    end
  end

  describe "uniqueness of name" do
    it "rejects two add-ons with the same name (case-insensitive)" do
      create(:add_on, name: "Oat Milk")
      duplicate = build(:add_on, name: "oat milk")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end

    it "allows reusing a name after the original is deleted" do
      old = create(:add_on, name: "Oat Milk")
      old.destroy
      expect(build(:add_on, name: "Oat Milk")).to be_valid
    end
  end
end
