# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Drinks", type: :request do
  describe "GET /admin/drinks" do
    context "when not signed in" do
      it "redirects to the login page" do
        get admin_drinks_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a non-admin user" do
      before { sign_in create(:user) }

      it "redirects with an authorization error" do
        get admin_drinks_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed in as admin" do
      before { sign_in create(:user, :admin) }

      it "returns success" do
        get admin_drinks_path
        expect(response).to have_http_status(:ok)
      end

      it "lists existing drinks" do
        drink = create(:drink, name: "Cappuccino")
        get admin_drinks_path
        expect(response.body).to include("Cappuccino")
      end
    end
  end

  describe "POST /admin/drinks" do
    context "when not signed in" do
      it "redirects to the login page" do
        post admin_drinks_path, params: { drink: { name: "Latte", base_price: 4.00 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a non-admin user" do
      before { sign_in create(:user) }

      it "redirects with an authorization error" do
        post admin_drinks_path, params: { drink: { name: "Latte", base_price: 4.00 } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/drinks/:id" do
    let!(:drink) { create(:drink) }

    context "when not signed in" do
      it "redirects to the login page" do
        delete admin_drink_path(drink)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a non-admin user" do
      before { sign_in create(:user) }

      it "redirects with an authorization error" do
        delete admin_drink_path(drink)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /admin/drinks/new" do
    before { sign_in create(:user, :admin) }

    it "renders the new drink form" do
      get new_admin_drink_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("New drink")
    end
  end

  describe "POST /admin/drinks" do
    before { sign_in create(:user, :admin) }

    context "with valid params" do
      let(:valid_params) { { drink: { name: "Flat White", description: "Smooth and velvety", base_price: 5.00 } } }

      it "creates a drink and redirects to the index" do
        expect { post admin_drinks_path, params: valid_params }.to change(Drink, :count).by(1)
        expect(response).to redirect_to(admin_drinks_path)
        follow_redirect!
        expect(response.body).to include("Flat White")
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { drink: { name: "", base_price: nil } } }

      it "does not create a drink and re-renders the form" do
        expect { post admin_drinks_path, params: invalid_params }.not_to change(Drink, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/drinks/:id" do
    before { sign_in create(:user, :admin) }

    it "shows the drink" do
      drink = create(:drink, name: "Mocha")
      get admin_drink_path(drink)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mocha")
    end
  end

  describe "GET /admin/drinks/:id/edit" do
    before { sign_in create(:user, :admin) }

    it "renders the edit form" do
      drink = create(:drink, name: "Cortado")
      get edit_admin_drink_path(drink)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cortado")
    end
  end

  describe "PATCH /admin/drinks/:id" do
    let(:drink) { create(:drink, name: "Old Name", base_price: 3.00) }

    before { sign_in create(:user, :admin) }

    context "with valid params" do
      it "updates the drink and redirects to the index" do
        patch admin_drink_path(drink), params: { drink: { name: "New Name", base_price: 4.50 } }
        expect(response).to redirect_to(admin_drinks_path)
        expect(drink.reload.name).to eq("New Name")
        expect(drink.reload.base_price).to eq(4.50)
      end
    end

    context "with invalid params" do
      it "does not update and re-renders the form" do
        patch admin_drink_path(drink), params: { drink: { name: "", base_price: -5 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(drink.reload.name).to eq("Old Name")
      end
    end
  end

  describe "DELETE /admin/drinks/:id" do
    before { sign_in create(:user, :admin) }

    it "deletes the drink and redirects to the index" do
      drink = create(:drink)
      expect { delete admin_drink_path(drink) }.to change(Drink, :count).by(-1)
      expect(response).to redirect_to(admin_drinks_path)
    end

    it "deletes the drink and cascades to order items that referenced it" do
      drink = create(:drink, name: "Latte To Remove")
      order = create(:order, status: :cart)
      create(:order_item, order: order, drink: drink)

      expect { delete admin_drink_path(drink) }.to change(Drink, :count).by(-1)
        .and change(OrderItem, :count).by(-1)
      expect(response).to redirect_to(admin_drinks_path)
      follow_redirect!
      expect(response.body).to include("successfully deleted")
    end
  end
end
