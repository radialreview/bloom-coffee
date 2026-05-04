module Api
  module V1
    class OrdersController < BaseController
      post "/" do
        payload = parsed_body
        customer_name = payload["customer_name"].to_s.strip
        items_payload = payload["items"]

        halt 422, json(error: "Customer name is required.") if customer_name.empty?
        halt 422, json(error: "Customer name is too long (120 characters max).") if customer_name.length > 120
        halt 422, json(error: "Items are required.") unless items_payload.is_a?(Array) && items_payload.any?

        drink_ids = items_payload.map { |item| item["drink_id"].to_i }
        add_on_ids = items_payload.flat_map { |item| Array(item["add_on_ids"]).map(&:to_i) }.uniq

        drinks_by_id = Drink.where(id: drink_ids).index_by(&:id)
        add_ons_by_id = add_on_ids.any? ? AddOn.where(id: add_on_ids).index_by(&:id) : {}

        items_payload.each_with_index do |item_payload, index|
          drink = drinks_by_id[item_payload["drink_id"].to_i]
          halt 422, json(error: "Item #{index + 1} has an invalid drink.") unless drink

          quantity = item_payload["quantity"].to_i
          halt 422, json(error: "Item #{index + 1} quantity must be at least 1.") if quantity <= 0
          halt 422, json(error: "Item #{index + 1} quantity cannot exceed 20.") if quantity > 20

          Array(item_payload["add_on_ids"]).each do |add_on_id|
            halt 422, json(error: "Item #{index + 1} has an invalid add-on.") unless add_ons_by_id[add_on_id.to_i]
          end
        end

        order = Order.transaction do
          order = Order.create!(customer_name: customer_name)
          total = 0.0

          items_payload.each do |item_payload|
            drink = drinks_by_id[item_payload["drink_id"].to_i]
            quantity = item_payload["quantity"].to_i
            add_ons = Array(item_payload["add_on_ids"]).map { |id| add_ons_by_id[id.to_i] }

            add_on_total = add_ons.sum(&:price)
            unit_price = drink.base_price
            line_total = ((unit_price + add_on_total) * quantity).round(2)

            order_item = order.order_items.create!(
              drink: drink,
              quantity: quantity,
              unit_price: unit_price,
              line_total: line_total,
            )

            add_ons.each do |add_on|
              order_item.order_item_add_ons.create!(add_on: add_on, price: add_on.price)
            end

            total += line_total
          end

          order.update!(total: total.round(2))
          order
        end

        status 201
        json(order: order.as_api_json)
      end

      get "/:token" do
        order = Order.find_by(public_token: params[:token]) || Order.find_by(id: params[:token])
        halt 404, json(error: "Not found") unless order
        json(order: order.as_api_json)
      end
    end
  end
end
