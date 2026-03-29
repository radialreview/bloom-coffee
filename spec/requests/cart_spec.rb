require "rails_helper"

RSpec.describe "Cart", type: :request do
  describe "GET /cart" do
    it "returns success" do
      get cart_path
      expect(response).to have_http_status(:ok)
    end

    it "shows an empty order message when cart is empty" do
      get cart_path
      expect(response.body).to include("Your order is empty")
    end
  end
end
