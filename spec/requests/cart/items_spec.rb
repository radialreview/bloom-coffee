require "rails_helper"

RSpec.describe "Cart::Items", type: :request do
  let!(:drink) { create(:drink, name: "Latte", base_price: 4.00) }
  let!(:add_on) { create(:add_on, name: "Oat Milk", price: 0.50) }

  describe "POST /cart/items" do
    it "adds a drink to the cart" do
      expect {
        post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      }.to change(OrderItem, :count).by(1)

      expect(response).to redirect_to(cart_path)
      follow_redirect!
      expect(response.body).to include("Latte")
    end

    it "adds a drink with add-ons" do
      post cart_items_path, params: {
        order_item: {
          drink_id: drink.id, quantity: 1,
          order_item_add_ons_attributes: [ { add_on_id: add_on.id } ]
        }
      }

      item = OrderItem.last
      expect(item.add_ons).to include(add_on)
    end

    it "deduplicates add-on IDs so the same add-on is only applied once" do
      post cart_items_path, params: {
        order_item: {
          drink_id: drink.id, quantity: 1,
          order_item_add_ons_attributes: [
            { add_on_id: add_on.id },
            { add_on_id: add_on.id }
          ]
        }
      }

      item = OrderItem.last
      expect(item.order_item_add_ons.count).to eq(1)
    end

    it "shows a flash notice" do
      post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      follow_redirect!
      expect(response.body).to include("Latte added to your order")
    end

    it "redirects with an alert when drink_id is missing" do
      post cart_items_path, params: { order_item: { drink_id: nil, quantity: 1 } }
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include("Could not add item to order")
    end
  end

  describe "PATCH /cart/items/:id" do
    it "updates the quantity" do
      post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      item = OrderItem.last

      patch cart_item_path(item), params: { quantity: 3 }
      expect(item.reload.quantity).to eq(3)
      expect(response).to redirect_to(cart_path)
    end

    it "rejects zero quantity" do
      post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      item = OrderItem.last

      patch cart_item_path(item), params: { quantity: 0 }
      expect(item.reload.quantity).to eq(1)
      expect(response).to redirect_to(cart_path)
    end

    it "rejects negative quantity" do
      post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      item = OrderItem.last

      patch cart_item_path(item), params: { quantity: -3 }
      expect(item.reload.quantity).to eq(1)
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "DELETE /cart/items/:id" do
    it "removes the item from the order" do
      post cart_items_path, params: { order_item: { drink_id: drink.id, quantity: 1 } }
      item = OrderItem.last

      expect {
        delete cart_item_path(item)
      }.to change(OrderItem, :count).by(-1)

      expect(response).to redirect_to(cart_path)
      follow_redirect!
      expect(response.body).to include("Item removed from your order")
    end
  end

  describe "running total" do
    it "reflects the correct total with add-ons and quantity" do
      post cart_items_path, params: {
        order_item: {
          drink_id: drink.id, quantity: 2,
          order_item_add_ons_attributes: [ { add_on_id: add_on.id } ]
        }
      }

      get cart_path
      expect(response.body).to include("$9.00")
    end
  end
end
