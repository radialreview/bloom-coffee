module Api
  module V1
    class DrinksController < BaseController
      get "/" do
        drinks = Drink.order(:id).map(&:as_api_json)
        json(drinks: drinks)
      end

      post "/" do
        authenticate_admin!
        payload = parsed_body

        drink = Drink.create!(
          name: payload["name"].to_s.strip,
          description: payload["description"].to_s.strip,
          base_price: payload["base_price"],
        )

        status 201
        json(drink: drink.as_api_json)
      end

      patch "/:id" do
        authenticate_admin!
        payload = parsed_body
        drink = Drink.find(params[:id])

        drink.update!(
          name: payload["name"].to_s.strip,
          description: payload["description"].to_s.strip,
          base_price: payload["base_price"],
        )

        json(drink: drink.as_api_json)
      end

      delete "/:id" do
        authenticate_admin!
        drink = Drink.find(params[:id])
        drink.destroy!
        status 204
      end
    end
  end
end
