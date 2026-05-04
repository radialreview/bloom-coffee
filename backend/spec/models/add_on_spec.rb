require "spec_helper"

RSpec.describe AddOn, type: :model do
  it "is valid with a name and non-negative price" do
    add_on = build(:add_on)
    expect(add_on).to be_valid
  end

  it "is invalid without a name" do
    add_on = build(:add_on, name: "")
    expect(add_on).not_to be_valid
  end

  it "is invalid with a negative price" do
    add_on = build(:add_on, price: -0.01)
    expect(add_on).not_to be_valid
  end

  it "requires a unique name" do
    existing = create(:add_on, name: "Oat Milk")
    duplicate = build(:add_on, name: "Oat Milk")
    expect(duplicate).not_to be_valid
  end
end
