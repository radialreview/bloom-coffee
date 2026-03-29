require "rails_helper"

RSpec.describe User, type: :model do
  it "defaults to the user role" do
    expect(build(:user).role).to eq("user")
  end

  it "supports the admin role" do
    expect(build(:user, :admin).role).to eq("admin")
  end
end
