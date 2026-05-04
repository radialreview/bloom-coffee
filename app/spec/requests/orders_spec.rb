require "rails_helper"

RSpec.describe "Orders", type: :request do
  let!(:drink) { create(:drink, name: "Latte", price: 4.00) }
  let!(:add_on) { create(:add_on, name: "Oat Milk", price: 0.50) }

  describe "GET /orders" do
    it "shows no orders message when none submitted" do
      get orders_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No orders yet")
    end

    it "shows the latest submitted order" do
      post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      post orders_path, params: { order: { customer_name: "Sam" } }

      get orders_path
      expect(response.body).to include("Sam")
      expect(response.body).to include("Latte")
    end
  end

  describe "POST /orders" do
    context "with a valid name and items in cart" do
      it "submits the order and redirects to confirmation" do
        post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
        order = Order.last

        post orders_path, params: { order: { customer_name: "Sam" } }

        expect(order.reload.status).to eq("submitted")
        expect(order.customer_name).to eq("Sam")
        expect(response).to redirect_to(order_path(order))
      end

      it "snapshots total_price on submit" do
        post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 2 } }
        post orders_path, params: { order: { customer_name: "Sam" } }

        order = Order.submitted.last
        expect(order.total_price).to eq(8.00)
      end

      it "clears the session so a new cart is created" do
        post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }

        post orders_path, params: { order: { customer_name: "Sam" } }

        get cart_path
        expect(response.body).to include("Your cart is empty")
      end

      it "stores last order in session" do
        post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
        post orders_path, params: { order: { customer_name: "Sam" } }

        get orders_path
        expect(response.body).to include("Latest Order")
      end
    end

    context "with a blank name" do
      it "redirects back to cart with an alert" do
        post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }

        post orders_path, params: { order: { customer_name: "" } }

        expect(response).to redirect_to(cart_path)
        follow_redirect!
        expect(response.body).to include("Please provide your name for pickup")
      end
    end

    context "with an empty cart" do
      it "redirects back to cart with an alert" do
        post orders_path, params: { order: { customer_name: "Sam" } }

        expect(response).to redirect_to(cart_path)
        follow_redirect!
        expect(response.body).to include("Your cart is empty")
      end
    end
  end

  describe "GET /orders/:id" do
    it "shows the confirmation page for a submitted order" do
      post cart_items_path, params: {
        order_item: {
          drink_id: drink.id, quantity: 2,
          order_item_add_ons_attributes: [ { add_on_id: add_on.id } ]
        }
      }
      order = Order.last

      post orders_path, params: { order: { customer_name: "Sam" } }
      order.reload

      get order_path(order)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Order ##{order.id} confirmed")
      expect(response.body).to include("Sam")
      expect(response.body).to include("Latte")
      expect(response.body).to include("Oat Milk")
      expect(response.body).to include("$9.00")
    end

    it "redirects to root for an unknown id" do
      get order_path(id: 999_999)
      expect(response).to redirect_to(root_path)
    end
  end
end
