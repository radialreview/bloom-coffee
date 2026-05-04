require "spec_helper"

RSpec.describe Drink, type: :model do
  it "is valid with name and positive base price" do
    drink = build(:drink)
    expect(drink).to be_valid
  end

  it "is invalid without a name" do
    drink = build(:drink, name: "")
    expect(drink).not_to be_valid
  end

  it "is invalid with non-positive base price" do
    drink = build(:drink, base_price: 0)
    expect(drink).not_to be_valid
  end
end
