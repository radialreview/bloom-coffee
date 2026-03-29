require "rails_helper"

RSpec.describe "Menu", type: :request do
  describe "GET /menu" do
    it "returns success without authentication" do
      get menu_index_path
      expect(response).to have_http_status(:ok)
    end

    it "lists drinks" do
      create(:drink, name: "Cappuccino", base_price: 4.50)
      create(:drink, name: "Americano", base_price: 3.00)

      get menu_index_path
      expect(response.body).to include("Cappuccino")
      expect(response.body).to include("Americano")
      expect(response.body).to include("$4.50")
    end
  end

  describe "GET /menu/:id" do
    it "shows the drink with add-ons" do
      drink = create(:drink, name: "Latte", base_price: 4.00)
      create(:add_on, name: "Oat Milk", price: 0.50)

      get menu_path(drink)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Latte")
      expect(response.body).to include("$4.00")
      expect(response.body).to include("Oat Milk")
      expect(response.body).to include("$0.50")
    end
  end
end
