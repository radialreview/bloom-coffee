module Api
  module V1
    class OrdersController < BaseController
      post "/" do
        payload = parsed_body
        customer_name = payload["customer_name"].to_s.strip
        items_payload = payload["items"]

        halt 422, json(error: "Customer name is required.") if customer_name.empty?
        halt 422, json(error: "Items are required.") unless items_payload.is_a?(Array) && items_payload.any?

        order = Order.transaction do
          order = Order.create!(customer_name: customer_name)
          total = 0.0

          items_payload.each_with_index do |item_payload, index|
            drink = Drink.find_by(id: item_payload["drink_id"].to_i)
            halt 422, json(error: "Item #{index + 1} has an invalid drink.") unless drink

            quantity = item_payload["quantity"].to_i
            halt 422, json(error: "Item #{index + 1} quantity must be at least 1.") if quantity <= 0

            add_ons = Array(item_payload["add_on_ids"]).map do |add_on_id|
              add_on = AddOn.find_by(id: add_on_id.to_i)
              halt 422, json(error: "Item #{index + 1} has an invalid add-on.") unless add_on
              add_on
            end

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

      get "/:id" do
        order = Order.find(params[:id])
        json(order: order.as_api_json)
      end
    end
  end
end
