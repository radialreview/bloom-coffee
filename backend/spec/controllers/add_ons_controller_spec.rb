require "spec_helper"

RSpec.describe "Add-ons API", type: :request do
  it "lists add-ons publicly" do
    create(:add_on, name: "Oat Milk", price: 0.5)

    get "/api/v1/add_ons"

    expect(last_response.status).to eq(200)
    expect(parsed_json["add_ons"].map { |add_on| add_on["name"] }).to include("Oat Milk")
  end

  it "blocks update without auth token" do
    add_on = create(:add_on, name: "Vanilla", price: 0.5)

    patch "/api/v1/add_ons/#{add_on.id}", { name: "Vanilla+", price: 0.75 }.to_json, json_headers

    expect(last_response.status).to eq(401)
  end

  it "updates add-on with auth token" do
    token = login_token
    add_on = create(:add_on, name: "Vanilla", price: 0.5)

    patch "/api/v1/add_ons/#{add_on.id}", { name: "Vanilla+", price: 0.75 }.to_json, json_headers(token: token)

    expect(last_response.status).to eq(200)
    expect(add_on.reload.name).to eq("Vanilla+")
  end
end
