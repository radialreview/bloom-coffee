require_relative "./config/environment"

class BloomCoffeeAPI
  def self.app
    Rack::Builder.new do
      use Rack::Cors do
        allow do
          origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173")
          resource "*", headers: :any, methods: %i[get post patch delete options], expose: ["Authorization"]
        end
      end

      map "/api/v1/admin" do
        run Api::V1::SessionsController
      end

      map "/api/v1/drinks" do
        run Api::V1::DrinksController
      end

      map "/api/v1/add_ons" do
        run Api::V1::AddOnsController
      end

      map "/api/v1/orders" do
        run Api::V1::OrdersController
      end
    end
  end
end
