require "rails_helper"

RSpec.describe "Ordering flow", type: :system do
  before do
    driven_by :rack_test
  end

  let!(:latte) { create(:drink, name: "Latte", base_price: 4.50) }
  let!(:mocha) { create(:drink, name: "Mocha", base_price: 5.00) }
  let!(:oat_milk) { create(:add_on, name: "Oat Milk", price: 0.75) }

  it "lets a customer browse the menu, add items to cart, and submit an order" do
    visit root_path
    click_on "View Menu"

    expect(page).to have_content("Latte")
    expect(page).to have_content("Mocha")

    click_on "Latte"
    expect(page).to have_content("Customize")

    check "Oat Milk"
    click_on "Add to order"

    expect(page).to have_content("Latte added to your order")
    expect(page).to have_content("$5.25")

    click_on "Add more drinks"
    click_on "Mocha"
    click_on "Add to order"

    expect(page).to have_content("Mocha added to your order")

    fill_in "Name for pickup", with: "Jordan"
    click_on "Place order"

    expect(page).to have_content("confirmed")
    expect(page).to have_content("Jordan")
    expect(page).to have_content("Latte")
    expect(page).to have_content("Mocha")
  end
end
