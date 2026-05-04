require "sinatra/base"
require "sinatra/json"
require "dotenv/load"
require "jwt"
require "bcrypt"
require "json"
require "rack/cors"

class BloomCoffeeAPI < Sinatra::Base
  configure do
    set :show_exceptions, false
    set :jwt_secret, ENV.fetch("JWT_SECRET", "dev-secret-change-me")
    set :admin_email, ENV.fetch("ADMIN_EMAIL", "admin@bloom.coffee")
    set :admin_password_hash, BCrypt::Password.create(ENV.fetch("ADMIN_PASSWORD", "password123"))
    set :drinks, [
      { id: 1, name: "Drip Coffee", description: "House roast brewed fresh.", base_price: 3.25 },
      { id: 2, name: "Latte", description: "Espresso with steamed milk.", base_price: 4.75 },
    ]
  end

  use Rack::Cors do
    allow do
      origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173")
      resource "*", headers: :any, methods: %i[get post patch delete options], expose: ["Authorization"]
    end
  end

  before do
    content_type :json
  end

  options "*" do
    200
  end

  post "/api/v1/admin/login" do
    payload = JSON.parse(request.body.read)
    email = payload["email"].to_s.strip
    password = payload["password"].to_s

    unless valid_admin_credentials?(email, password)
      halt 401, json(error: "Invalid email or password.")
    end

    token = JWT.encode({ sub: email, exp: Time.now.to_i + 60 * 60 * 8 }, settings.jwt_secret, "HS256")
    json(token:, admin: { email: settings.admin_email })
  rescue JSON::ParserError
    halt 400, json(error: "Invalid JSON body.")
  end

  get "/api/v1/admin/session" do
    admin = require_authentication!
    json(authenticated: true, admin:)
  end

  post "/api/v1/admin/logout" do
    require_authentication!
    json(message: "Logged out.")
  end

  get "/api/v1/drinks" do
    json(drinks: settings.drinks)
  end

  post "/api/v1/drinks" do
    require_authentication!
    payload = JSON.parse(request.body.read)
    attributes = sanitize_drink_attributes(payload)
    errors = validate_drink(attributes)
    halt 422, json(error: errors.join(", ")) unless errors.empty?

    next_id = settings.drinks.map { |item| item[:id] }.max.to_i + 1
    drink = attributes.merge(id: next_id)
    settings.drinks << drink
    status 201
    json(drink:)
  rescue JSON::ParserError
    halt 400, json(error: "Invalid JSON body.")
  end

  patch "/api/v1/drinks/:id" do
    require_authentication!
    payload = JSON.parse(request.body.read)
    attributes = sanitize_drink_attributes(payload)
    errors = validate_drink(attributes)
    halt 422, json(error: errors.join(", ")) unless errors.empty?

    drink = find_drink!(params[:id])
    drink[:name] = attributes[:name]
    drink[:description] = attributes[:description]
    drink[:base_price] = attributes[:base_price]
    json(drink:)
  rescue JSON::ParserError
    halt 400, json(error: "Invalid JSON body.")
  end

  delete "/api/v1/drinks/:id" do
    require_authentication!
    drink = find_drink!(params[:id])
    settings.drinks.delete(drink)
    status 204
  end

  not_found do
    json(error: "Not found")
  end

  error do
    status 500
    json(error: "Unexpected server error")
  end

  helpers do
    def valid_admin_credentials?(email, password)
      email == settings.admin_email && BCrypt::Password.new(settings.admin_password_hash) == password
    end

    def require_authentication!
      header = request.env["HTTP_AUTHORIZATION"].to_s
      token = header.start_with?("Bearer ") ? header.split(" ", 2).last : nil
      halt 401, json(error: "Unauthorized") unless token

      decoded_token = JWT.decode(token, settings.jwt_secret, true, algorithm: "HS256")
      { email: decoded_token.dig(0, "sub") }
    rescue JWT::DecodeError, JWT::ExpiredSignature
      halt 401, json(error: "Unauthorized")
    end

    def sanitize_drink_attributes(payload)
      base_price = payload["base_price"]
      parsed_base_price = begin
        Float(base_price)
      rescue ArgumentError, TypeError
        nil
      end

      {
        name: payload["name"].to_s.strip,
        description: payload["description"].to_s.strip,
        base_price: parsed_base_price&.round(2),
      }
    end

    def validate_drink(attributes)
      errors = []
      errors << "Name is required." if attributes[:name].empty?
      errors << "Base price must be greater than 0." if attributes[:base_price].nil? || attributes[:base_price] <= 0
      errors
    end

    def find_drink!(id)
      drink = settings.drinks.find { |item| item[:id] == id.to_i }
      halt 404, json(error: "Drink not found.") unless drink

      drink
    end
  end
end
