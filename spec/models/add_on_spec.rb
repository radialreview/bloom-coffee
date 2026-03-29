require "rails_helper"

RSpec.describe AddOn, type: :model do
  it "is valid with valid attributes" do
    expect(build(:add_on)).to be_valid
  end

  it "requires a name" do
    expect(build(:add_on, name: nil)).not_to be_valid
  end

  it "requires a unique name" do
    create(:add_on, name: "Oat Milk")
    expect(build(:add_on, name: "Oat Milk")).not_to be_valid
  end

  it "requires a price" do
    expect(build(:add_on, price: nil)).not_to be_valid
  end

  it "requires a non-negative price" do
    expect(build(:add_on, price: -1)).not_to be_valid
  end

  it "allows a zero price" do
    expect(build(:add_on, price: 0)).to be_valid
  end

  it "rejects a price that exceeds the database column limit" do
    add_on = build(:add_on, price: 1_000_000)
    expect(add_on).not_to be_valid
    expect(add_on.errors[:price]).to include("must be less than 1000000")
  end
end
