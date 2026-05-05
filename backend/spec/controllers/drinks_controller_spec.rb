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

  it "returns 422 for an out-of-range base price" do
    token = login_token

    post "/api/v1/drinks", { name: "Gold Mocha", description: "Fancy", base_price: 1_000_000.00 }.to_json, json_headers(token: token)

    expect(last_response.status).to eq(422)
    expect(parsed_json["error"]).to match(/Base price/i)
  end

  it "updates a drink with auth token" do
    token = login_token
    drink = create(:drink, name: "Latte", base_price: 4.75)

    patch "/api/v1/drinks/#{drink.id}", { name: "Oat Latte", description: "With oat milk", base_price: 5.25 }.to_json, json_headers(token: token)

    expect(last_response.status).to eq(200)
    drink.reload
    expect(drink.name).to eq("Oat Latte")
    expect(drink.base_price).to eq(5.25)
  end

  it "blocks update without auth token" do
    drink = create(:drink, name: "Latte")

    patch "/api/v1/drinks/#{drink.id}", { name: "Oat Latte", base_price: 5.25 }.to_json, json_headers

    expect(last_response.status).to eq(401)
  end

  it "deletes a drink with auth token" do
    token = login_token
    drink = create(:drink, name: "Drip")

    delete "/api/v1/drinks/#{drink.id}", {}, json_headers(token: token)

    expect(last_response.status).to eq(204)
    expect(Drink.find_by(id: drink.id)).to be_nil
  end

  it "blocks delete without auth token" do
    drink = create(:drink)

    delete "/api/v1/drinks/#{drink.id}", {}, json_headers

    expect(last_response.status).to eq(401)
  end

  it "returns 404 for non-existent drink" do
    token = login_token

    patch "/api/v1/drinks/999999", { name: "Ghost" }.to_json, json_headers(token: token)

    expect(last_response.status).to eq(404)
  end
end
