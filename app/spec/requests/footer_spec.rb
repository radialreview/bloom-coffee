require "rails_helper"

RSpec.describe "Footer primary nav", type: :request do
  it "renders primary nav links with correct hrefs" do
    get root_path

    nav = Nokogiri::HTML(response.body).at_css('nav[aria-label="Primary"]')
    expect(nav).to be_present

    expect_nav_href = lambda do |label, expected_href|
      link = nav.css("a").find { |a| a.text.gsub(/\s+/, " ").strip == label }
      expect(link).not_to be_nil
      expect(link["href"]).to eq(expected_href)
    end

    expect_nav_href.call("Menu", root_path)
    expect_nav_href.call("Cart", cart_path)
    expect_nav_href.call("Order", orders_path)
    expect_nav_href.call("Settings", settings_path)
  end
end
