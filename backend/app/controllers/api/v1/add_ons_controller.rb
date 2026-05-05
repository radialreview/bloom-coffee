module Api
  module V1
    class AddOnsController < BaseController
      get "/" do
        add_ons = AddOn.order(:id).map(&:as_api_json)
        json(add_ons: add_ons)
      end

      post "/" do
        authenticate_admin!
        payload = parsed_body

        add_on = AddOn.create!(
          name: payload["name"].to_s.strip,
          price: payload["price"],
        )

        status 201
        json(add_on: add_on.as_api_json)
      end

      patch "/:id" do
        authenticate_admin!
        payload = parsed_body
        add_on = AddOn.find(params[:id])

        add_on.update!(
          name: payload["name"].to_s.strip,
          price: payload["price"],
        )

        json(add_on: add_on.as_api_json)
      end

      delete "/:id" do
        authenticate_admin!
        add_on = AddOn.find(params[:id])
        add_on.destroy!
        status 204
      end
    end
  end
end
