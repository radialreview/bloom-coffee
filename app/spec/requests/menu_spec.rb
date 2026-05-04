require "rails_helper"

RSpec.describe "Menu", type: :request do
  describe "GET /" do
    it "shows the menu at root" do
      create(:drink, name: "Latte", price: 5, description: "Milk.")

      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Latte")
      expect(response.body).to include("$5.00")
    end
  end

  describe "GET /menu" do
    it "shows the current drinks, no sign in required" do
      create(:drink, name: "Latte", price: 5, description: "With steamed milk.")

      get menu_index_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Latte")
      expect(response.body).to include("With steamed milk.")
      expect(response.body).to include("$5.00")
    end

    it "shows an empty state when there are no drinks" do
      get menu_index_path
      expect(response.body).to include("No drinks on the menu yet")
    end
  end

  describe "GET /menu/:id" do
    it "shows the drink with add-ons" do
      drink = create(:drink, name: "Latte", price: 4.00)
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
