require "rails_helper"

RSpec.describe "Footer primary nav", type: :request do
  it "links to the admin dashboard" do
    get root_path
    expect(response.body).to include(%(href="#{admin_root_path}"))
    expect(response.body).to include(">Management<")
  end

  it "sends guests who open /admin to the sign-in page" do
    get admin_root_path
    expect(response).to redirect_to(admin_login_path)
  end

  it "allows a signed-in administrator to open /admin" do
    admin = create(:admin)
    post admin_login_path, params: { session: { email: admin.email, password: "password123" } }

    get admin_root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Manage menu")
  end
end
