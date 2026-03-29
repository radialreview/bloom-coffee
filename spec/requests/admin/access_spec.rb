# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin access", type: :request do
  describe "GET /admin" do
    context "when not signed in" do
      it "redirects to the login page" do
        get admin_root_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as an admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin, scope: :user }

      it "shows the admin dashboard" do
        get admin_root_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as a non-admin user" do
      let(:user) { create(:user) }

      before { sign_in user, scope: :user }

      it "redirects to the home page with an alert" do
        get admin_root_path

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access the admin area.")
      end
    end
  end

  describe "POST /admin/login" do
    let!(:admin) do
      create(:user, :admin, password: "correct-horse-battery", password_confirmation: "correct-horse-battery")
    end

    it "redirects to the admin dashboard when credentials are valid" do
      post user_session_path, params: { user: { email: admin.email, password: "correct-horse-battery" } }

      expect(response).to redirect_to(admin_root_path)
    end

    it "does not sign in when the password is invalid" do
      post user_session_path, params: { user: { email: admin.email, password: "wrong-password" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /admin/logout" do
    let(:admin) { create(:user, :admin) }

    before { sign_in admin, scope: :user }

    it "signs out and prevents access to the admin area until logging in again" do
      delete destroy_user_session_path

      expect(response).to redirect_to(new_user_session_path)

      get admin_root_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
