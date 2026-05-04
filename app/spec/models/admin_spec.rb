require "rails_helper"

RSpec.describe Admin, type: :model do
  it "requires an email" do
    admin = Admin.new(password: "password123", password_confirmation: "password123")
    expect(admin).not_to be_valid
    expect(admin.errors[:email]).to include("can't be blank")
  end

  it "requires a password on create" do
    admin = Admin.new(email: "solo@example.test")
    expect(admin).not_to be_valid
    expect(admin.errors[:password]).to include("can't be blank")
  end

  it "requires password to be at least 8 characters on create" do
    admin = Admin.new(
      email: "short@example.test",
      password: "short",
      password_confirmation: "short"
    )
    expect(admin).not_to be_valid
    expect(admin.errors[:password]).to include("is too short (minimum is 8 characters)")
  end

  it "creates a persisted record from the default factory" do
    expect { create(:admin) }.to change(Admin, :count).by(1)
  end

  it "rejects a duplicate email (case-insensitive)" do
    create(:admin, email: "owner@example.test")
    dup = build(:admin, email: "OWNER@EXAMPLE.TEST")
    expect(dup).not_to be_valid
    expect(dup.errors[:email]).to include("has already been taken")
  end
end
