ENV["RACK_ENV"] = "test"

require "rack/test"
require "factory_bot"
require "json"
require_relative "../config/environment"
require_relative "../app"

Dir[File.expand_path("./support/**/*.rb", __dir__)].sort.each { |file| require file }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods
  config.include RequestHelpers

  config.define_derived_metadata do |metadata|
    metadata[:type] ||= :request if metadata[:file_path].include?("/spec/controllers/")
    metadata[:type] ||= :model if metadata[:file_path].include?("/spec/models/")
  end

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    [OrderItemAddOn, OrderItem, Order, AddOn, Drink, Admin].each(&:delete_all)
  end

  config.before(:each) do
    admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")
    create(:admin, email: ENV.fetch("ADMIN_EMAIL", "admin@bloom.coffee"), password: admin_password, password_confirmation: admin_password)
  end

  def app
    BloomCoffeeAPI.app
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
