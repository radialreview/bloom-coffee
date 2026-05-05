module RequestHelpers
  def parsed_json
    JSON.parse(last_response.body)
  end

  def json_headers(token: nil)
    headers = { "CONTENT_TYPE" => "application/json" }
    headers["HTTP_AUTHORIZATION"] = "Bearer #{token}" if token
    headers
  end

  def login_token(email: ENV.fetch("ADMIN_EMAIL", "admin@bloom.coffee"), password: ENV.fetch("ADMIN_PASSWORD", "password123"))
    post "/api/v1/admin/login", { email: email, password: password }.to_json, json_headers
    parsed_json["token"]
  end
end
