require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns success" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "displays the app name" do
      get root_path
      expect(response.body).to include("Bloom Coffee")
    end

    it "links to the menu" do
      get root_path
      expect(response.body).to include(menu_index_path)
    end
  end
end
