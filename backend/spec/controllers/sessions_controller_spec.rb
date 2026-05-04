require "spec_helper"

RSpec.describe "Sessions API", type: :request do
  it "logs in with valid credentials" do
    post "/api/v1/admin/login", { email: "admin@bloom.coffee", password: "password123" }.to_json, json_headers

    expect(last_response.status).to eq(200)
    expect(parsed_json["token"]).to be_a(String)
  end

  it "rejects invalid credentials" do
    post "/api/v1/admin/login", { email: "admin@bloom.coffee", password: "wrong" }.to_json, json_headers

    expect(last_response.status).to eq(401)
  end

  it "returns session details for authenticated admin" do
    token = login_token
    get "/api/v1/admin/session", {}, json_headers(token: token)

    expect(last_response.status).to eq(200)
    expect(parsed_json["authenticated"]).to eq(true)
  end
end
