require "rails_helper"

RSpec.describe "Admin::AddOns", type: :request do
  def sign_in_admin
    admin = create(:admin)
    post admin_login_path, params: { session: { email: admin.email, password: "password123" } }
    admin
  end

  describe "auth" do
    it "redirects index to admin login when not signed in" do
      get admin_add_ons_path
      expect(response).to redirect_to(admin_login_path)
    end

    it "redirects new to admin login when not signed in" do
      get new_admin_add_on_path
      expect(response).to redirect_to(admin_login_path)
    end

    it "redirects create to admin login when not signed in" do
      post admin_add_ons_path, params: { add_on: { name: "X", price: 1 } }
      expect(response).to redirect_to(admin_login_path)
    end
  end

  context "when signed in" do
    before { sign_in_admin }

    describe "GET /admin/add_ons" do
      it "lists add-ons" do
        create(:add_on, name: "Oat milk")
        create(:add_on, name: "Extra shot")

        get admin_add_ons_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Oat milk")
        expect(response.body).to include("Extra shot")
      end

      it "shows the empty state when there are none" do
        get admin_add_ons_path
        expect(response.body).to include("No add-ons yet")
      end

      it "exposes the new add-on trigger" do
        get admin_add_ons_path
        expect(response.body).to include('id="new_add_on"')
        expect(response.body).to include("New add-on")
      end
    end

    describe "POST /admin/add_ons" do
      it "creates an add-on and redirects (HTML fallback)" do
        expect do
          post admin_add_ons_path, params: { add_on: { name: "Oat milk", price: "0.50" } }
        end.to change(AddOn, :count).by(1)

        expect(response).to redirect_to(admin_add_ons_path)
        expect(AddOn.last.name).to eq("Oat milk")
        expect(AddOn.last.price).to eq(0.50)
      end

      it "renders the form with errors when invalid" do
        post admin_add_ons_path, params: { add_on: { name: "", price: "-1" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("can&#39;t be blank").or include("can't be blank")
      end
    end

    describe "PATCH /admin/add_ons/:id" do
      let!(:add_on) { create(:add_on, name: "Oat milk", price: 0.5) }

      it "updates and redirects (HTML fallback)" do
        patch admin_add_on_path(add_on), params: { add_on: { name: "Oat milk", price: "0.75" } }
        expect(response).to redirect_to(admin_add_ons_path)
        expect(add_on.reload.price).to eq(0.75)
      end
    end

    describe "DELETE /admin/add_ons/:id" do
      let!(:add_on) { create(:add_on, name: "Oat milk") }

      it "deletes and redirects (HTML fallback)" do
        expect { delete admin_add_on_path(add_on) }.to change(AddOn, :count).by(-1)
        expect(AddOn.exists?(add_on.id)).to be(false)
        expect(response).to redirect_to(admin_add_ons_path)
      end

      it "responds to a turbo_stream destroy by removing the row" do
        delete admin_add_on_path(add_on),
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include(%(target="add_on_#{add_on.id}"))
        expect(response.body).to include("Deleted add-on &#39;Oat milk&#39;.")
      end
    end

    describe "Turbo Frame interactions" do
      it "renders the new form inside the new_add_on frame" do
        get new_admin_add_on_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="new_add_on"')
        expect(response.body).to include("Cancel")
      end

      it "renders the edit form inside the row's frame" do
        add_on = create(:add_on, name: "Oat milk")
        get edit_admin_add_on_path(add_on)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(%(id="add_on_#{add_on.id}"))
      end

      it "responds to a turbo_stream create with stream actions and no redirect" do
        post admin_add_ons_path,
          params: { add_on: { name: "Vanilla", price: "0.50" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include("Vanilla")
        expect(response.body).to include("new_add_on")
        expect(response.body).to include("Created add-on &#39;Vanilla&#39;.")
      end

      it "responds to a turbo_stream update with a stream that replaces the row" do
        add_on = create(:add_on, name: "Oat milk", price: 0.5)
        patch admin_add_on_path(add_on),
          params: { add_on: { name: "Oat milk", price: "0.75" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include(%(target="add_on_#{add_on.id}"))
      end
    end
  end
end
