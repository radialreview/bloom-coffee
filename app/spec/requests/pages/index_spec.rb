require "rails_helper"

RSpec.describe "Customer home menu", type: :request do
  it "shows drinks from the database on the home page" do
    create(:drink, name: "Americano", description: "Bold espresso + water", price: 3.00)

    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Americano")
    expect(response.body).to include("Bold espresso + water")
    expect(response.body).to include("$3.00")
  end

  it "shows an empty state when there are no drinks" do
    get root_path
    expect(response.body).to include("No drinks on the menu yet")
  end
end
