require "rails_helper"

RSpec.describe "Cart", type: :request do
  describe "GET /cart" do
    it "responds with ok and shows an empty cart when there are no items" do
      get cart_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Your cart is empty")
    end
  end
end
