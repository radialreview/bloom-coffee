require "rails_helper"

RSpec.describe "Admin authentication", type: :request do
  describe "AC1.1 login page" do
    it "responds with the admin sign-in page at /admin/login" do
      get "/admin/login"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Admin sign in")
    end

    it "sends guests from /admin to the sign-in page" do
      get "/admin"
      expect(response).to redirect_to(admin_login_path)
    end
  end

  describe "AC1.2 invalid credentials" do
    let!(:admin) { create(:admin) }

    it "does not sign in and shows an error" do
      post "/admin/login", params: { session: { email: admin.email, password: "wrong-password" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password")
    end
  end

  describe "AC1.2 valid credentials" do
    let!(:admin) { create(:admin) }

    it "redirects to the admin section" do
      post "/admin/login", params: { session: { email: admin.email, password: "password123" } }
      expect(response).to redirect_to("/admin")
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end

  describe "AC1.3 protected admin area" do
    it "allows a signed-in admin to view the admin area" do
      admin = create(:admin)
      post "/admin/login", params: { session: { email: admin.email, password: "password123" } }
      get "/admin"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Manage menu")
    end
  end

  describe "AC1.4 logout" do
    it "ends the session so admin routes require login again" do
      admin = create(:admin)
      post "/admin/login", params: { session: { email: admin.email, password: "password123" } }

      delete "/admin/logout"
      expect(response).to have_http_status(:redirect)

      get "/admin"
      expect(response).to redirect_to(admin_login_path)
    end
  end
end
