require "rails_helper"

RSpec.describe "Admin drinks", type: :request do
  def sign_in_admin
    admin = create(:admin)
    post admin_login_path, params: { session: { email: admin.email, password: "password123" } }
    admin
  end

  describe "guest access" do
    it "redirects to login for index" do
      get admin_drinks_path
      expect(response).to redirect_to(admin_login_path)
    end

    it "redirects to login for new" do
      get new_admin_drink_path
      expect(response).to redirect_to(admin_login_path)
    end
  end

  describe "create" do
    before { sign_in_admin }

    it "creates a drink and shows it in the list" do
      get admin_drinks_path
      expect(response).to have_http_status(:ok)

      expect do
        post admin_drinks_path, params: {
          drink: { name: "Latte", description: "Espresso and steamed milk", price: "4.50" }
        }
      end.to change(Drink, :count).by(1)

      expect(response).to redirect_to(admin_drinks_path)
      follow_redirect!
      expect(response.body).to include("Latte")
      expect(response.body).to include("Created drink")
    end

    it "renders new with errors when invalid" do
      post admin_drinks_path, params: { drink: { name: "", price: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("New drink")
    end
  end

  describe "edit and delete" do
    let!(:drink) { create(:drink, name: "Mocha", description: "Chocolate", price: 5.25) }

    before { sign_in_admin }

    it "updates a drink" do
      patch admin_drink_path(drink), params: {
        drink: { name: "Mocha grande", description: "Rich chocolate", price: "5.75" }
      }
      expect(response).to redirect_to(admin_drinks_path)
      drink.reload
      expect(drink.name).to eq("Mocha grande")
      expect(drink.price).to eq(5.75)
    end

    it "deletes a drink" do
      expect do
        delete admin_drink_path(drink)
      end.to change(Drink, :count).by(-1)
      expect(response).to redirect_to(admin_drinks_path)
    end
  end
end
