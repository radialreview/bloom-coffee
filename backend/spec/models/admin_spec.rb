require "spec_helper"

RSpec.describe Admin, type: :model do
  it "is valid with an email and password" do
    admin = build(:admin)
    expect(admin).to be_valid
  end

  it "requires a unique email" do
    existing = create(:admin, email: "unique@bloom.coffee")
    duplicate = build(:admin, email: existing.email)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include("has already been taken")
  end

  it "authenticates with correct password" do
    admin = create(:admin, password: "secret123", password_confirmation: "secret123")
    expect(admin.authenticate("secret123")).to eq(admin)
  end

  it "rejects incorrect password" do
    admin = create(:admin, password: "secret123", password_confirmation: "secret123")
    expect(admin.authenticate("wrong")).to be_falsey
  end
end
