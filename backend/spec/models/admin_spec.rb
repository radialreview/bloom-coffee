require "spec_helper"

RSpec.describe Admin, type: :model do
  it "is valid with an email and password" do
    admin = build(:admin)
    expect(admin).to be_valid
  end

  it "requires a unique email" do
    duplicate = build(:admin, email: "admin@bloom.coffee")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include("has already been taken")
  end
end
