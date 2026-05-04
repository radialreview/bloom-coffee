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
end
