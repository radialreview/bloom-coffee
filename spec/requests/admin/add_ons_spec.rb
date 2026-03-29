# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::AddOns", type: :request do
  describe "GET /admin/add_ons" do
    context "when not signed in" do
      it "redirects to the login page" do
        get admin_add_ons_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as admin" do
      before { sign_in create(:user, :admin) }

      it "returns success" do
        get admin_add_ons_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as a non-admin user" do
      before { sign_in create(:user) }

      it "redirects with an authorization error" do
        get admin_add_ons_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access the admin area.")
      end
    end
  end

  describe "POST /admin/add_ons" do
    context "when not signed in" do
      it "redirects to the login page" do
        post admin_add_ons_path, params: { add_on: { name: "Oat Milk", price: 0.75 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a non-admin user" do
      before { sign_in create(:user) }

      it "redirects with an authorization error" do
        post admin_add_ons_path, params: { add_on: { name: "Oat Milk", price: 0.75 } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/add_ons/:id" do
    let!(:add_on) { create(:add_on) }

    context "when not signed in" do
      it "redirects to the login page" do
        delete admin_add_on_path(add_on)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a non-admin user" do
      before { sign_in create(:user) }

      it "redirects with an authorization error" do
        delete admin_add_on_path(add_on)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "when signed in as admin" do
    let(:admin) { create(:user, :admin) }
    before { sign_in admin }

    describe "GET /admin/add_ons (index listing)" do
      it "lists add-ons alphabetically" do
        create(:add_on, name: "Vanilla Syrup")
        create(:add_on, name: "Extra Shot")
        get admin_add_ons_path
        expect(response.body).to include("Extra Shot")
        expect(response.body).to include("Vanilla Syrup")
      end
    end

    describe "GET /admin/add_ons/new" do
      it "returns success" do
        get new_admin_add_on_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/add_ons" do
      it "creates a valid add-on and redirects" do
        expect {
          post admin_add_ons_path, params: { add_on: { name: "Oat Milk", price: 0.75 } }
        }.to change(AddOn, :count).by(1)

        expect(response).to redirect_to(admin_add_ons_path)
        follow_redirect!
        expect(response.body).to include("Add-on was successfully created.")
      end

      it "re-renders the form with invalid data" do
        post admin_add_ons_path, params: { add_on: { name: "", price: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "GET /admin/add_ons/:id" do
      it "shows the add-on" do
        add_on = create(:add_on, name: "Almond Milk")
        get admin_add_on_path(add_on)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Almond Milk")
      end
    end

    describe "GET /admin/add_ons/:id/edit" do
      it "returns success" do
        add_on = create(:add_on)
        get edit_admin_add_on_path(add_on)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH /admin/add_ons/:id" do
      let!(:add_on) { create(:add_on, name: "Old Name", price: 0.50) }

      it "updates the add-on and redirects" do
        patch admin_add_on_path(add_on), params: { add_on: { name: "New Name", price: 1.00 } }
        expect(response).to redirect_to(admin_add_ons_path)
        follow_redirect!
        expect(response.body).to include("Add-on was successfully updated.")
        expect(add_on.reload.name).to eq("New Name")
      end

      it "re-renders the form with invalid data" do
        patch admin_add_on_path(add_on), params: { add_on: { name: "", price: -5 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE /admin/add_ons/:id" do
      it "destroys the add-on and redirects" do
        add_on = create(:add_on, name: "Gone")

        expect {
          delete admin_add_on_path(add_on)
        }.to change(AddOn, :count).by(-1)

        expect(response).to redirect_to(admin_add_ons_path)
        follow_redirect!
        expect(response.body).to include("Add-on was successfully deleted.")
      end

      it "deletes the add-on and cascades join rows on order items" do
        add_on = create(:add_on, name: "Syrup To Remove")
        order_item = create(:order_item)
        create(:order_item_add_on, order_item: order_item, add_on: add_on)

        expect { delete admin_add_on_path(add_on) }.to change(AddOn, :count).by(-1)
          .and change(OrderItemAddOn, :count).by(-1)
        expect(response).to redirect_to(admin_add_ons_path)
        follow_redirect!
        expect(response.body).to include("successfully deleted")
        expect(order_item.reload.add_ons).not_to include(add_on)
      end
    end
  end
end
