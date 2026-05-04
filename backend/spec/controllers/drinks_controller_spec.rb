require "spec_helper"

RSpec.describe "Drinks API", type: :request do
  it "lists drinks publicly" do
    create(:drink, name: "Latte")

    get "/api/v1/drinks"

    expect(last_response.status).to eq(200)
    expect(parsed_json["drinks"].map { |drink| drink["name"] }).to include("Latte")
  end

  it "blocks create without auth token" do
    post "/api/v1/drinks", { name: "Mocha", description: "Chocolate", base_price: 5.5 }.to_json, json_headers

    expect(last_response.status).to eq(401)
  end

  it "creates drink with auth token" do
    token = login_token

    post "/api/v1/drinks", { name: "Mocha", description: "Chocolate", base_price: 5.5 }.to_json, json_headers(token: token)

    expect(last_response.status).to eq(201)
    expect(Drink.find_by(name: "Mocha")).not_to be_nil
  end
end
