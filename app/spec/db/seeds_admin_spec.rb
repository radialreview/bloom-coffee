require "rails_helper"

RSpec.describe "db/seeds.rb (admin)" do
  around do |example|
    previous_email = ENV.fetch("ADMIN_EMAIL", nil)
    previous_password = ENV.fetch("ADMIN_PASSWORD", nil)
    ENV["ADMIN_EMAIL"] = "seeded-admin@example.test"
    ENV["ADMIN_PASSWORD"] = "password123"
    example.run
  ensure
    previous_email ? ENV["ADMIN_EMAIL"] = previous_email : ENV.delete("ADMIN_EMAIL")
    previous_password ? ENV["ADMIN_PASSWORD"] = previous_password : ENV.delete("ADMIN_PASSWORD")
  end

  it "creates exactly one admin when loaded twice" do
    load Rails.root.join("db/seeds.rb")
    load Rails.root.join("db/seeds.rb")
    expect(Admin.where(email: "seeded-admin@example.test").count).to eq(1)
    expect(Admin.find_by!(email: "seeded-admin@example.test").authenticate("password123")).to be_truthy
  end
end
