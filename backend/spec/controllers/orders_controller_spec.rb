require "spec_helper"

RSpec.describe "Orders API", type: :request do
  it "creates an order and returns an order number" do
    drink = create(:drink, name: "Drip", base_price: 3.25)
    add_on = create(:add_on, name: "Oat Milk", price: 0.5)

    post "/api/v1/orders", {
      customer_name: "Jordan",
      items: [
        { drink_id: drink.id, quantity: 2, add_on_ids: [add_on.id] },
      ],
    }.to_json, json_headers

    expect(last_response.status).to eq(201)
    expect(parsed_json.dig("order", "order_number")).to be >= 1000
    expect(parsed_json.dig("order", "total")).to eq(7.5)
  end

  it "returns validation error with empty customer name" do
    drink = create(:drink)

    post "/api/v1/orders", {
      customer_name: "",
      items: [{ drink_id: drink.id, quantity: 1, add_on_ids: [] }],
    }.to_json, json_headers

    expect(last_response.status).to eq(422)
  end

  it "calculates total correctly with multiple items and add-ons" do
    latte = create(:drink, name: "Latte", base_price: 4.75)
    drip = create(:drink, name: "Drip", base_price: 3.25)
    oat_milk = create(:add_on, name: "Oat Milk", price: 0.50)
    extra_shot = create(:add_on, name: "Extra Shot", price: 0.75)

    post "/api/v1/orders", {
      customer_name: "Avery",
      items: [
        { drink_id: latte.id, quantity: 1, add_on_ids: [oat_milk.id, extra_shot.id] },
        { drink_id: drip.id, quantity: 2, add_on_ids: [] },
      ],
    }.to_json, json_headers

    expect(last_response.status).to eq(201)
    order = parsed_json["order"]
    expect(order["items"].length).to eq(2)
    expect(order["items"][0]["line_total"]).to eq(6.0)
    expect(order["items"][1]["line_total"]).to eq(6.5)
    expect(order["total"]).to eq(12.5)
  end

  it "retrieves an existing order by id" do
    drink = create(:drink, name: "Latte", base_price: 4.75)

    post "/api/v1/orders", {
      customer_name: "Jordan",
      items: [{ drink_id: drink.id, quantity: 1, add_on_ids: [] }],
    }.to_json, json_headers

    order_id = parsed_json.dig("order", "id")

    get "/api/v1/orders/#{order_id}"

    expect(last_response.status).to eq(200)
    expect(parsed_json.dig("order", "customer_name")).to eq("Jordan")
    expect(parsed_json.dig("order", "total")).to eq(4.75)
  end

  it "returns 404 for non-existent order" do
    get "/api/v1/orders/999999"

    expect(last_response.status).to eq(404)
  end

  it "rejects order with no items" do
    post "/api/v1/orders", {
      customer_name: "Jordan",
      items: [],
    }.to_json, json_headers

    expect(last_response.status).to eq(422)
  end

  it "rejects order with invalid drink id" do
    post "/api/v1/orders", {
      customer_name: "Jordan",
      items: [{ drink_id: 999999, quantity: 1, add_on_ids: [] }],
    }.to_json, json_headers

    expect(last_response.status).to eq(422)
  end

  it "rejects order with zero quantity" do
    drink = create(:drink)

    post "/api/v1/orders", {
      customer_name: "Jordan",
      items: [{ drink_id: drink.id, quantity: 0, add_on_ids: [] }],
    }.to_json, json_headers

    expect(last_response.status).to eq(422)
  end

  it "includes add-on details in the order confirmation" do
    drink = create(:drink, name: "Latte", base_price: 4.75)
    oat_milk = create(:add_on, name: "Oat Milk", price: 0.50)

    post "/api/v1/orders", {
      customer_name: "Jordan",
      items: [{ drink_id: drink.id, quantity: 1, add_on_ids: [oat_milk.id] }],
    }.to_json, json_headers

    item = parsed_json.dig("order", "items", 0)
    expect(item["add_ons"].length).to eq(1)
    expect(item["add_ons"][0]["name"]).to eq("Oat Milk")
    expect(item["add_ons"][0]["price"]).to eq(0.5)
  end
end
