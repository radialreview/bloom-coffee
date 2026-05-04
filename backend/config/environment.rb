require "bundler/setup"
require "dotenv/load"
require "yaml"
require "erb"

require "sinatra/base"
require "jwt"
require "bcrypt"
require "time"
require "sinatra/json"
require "active_record"
require "rack/cors"

# Ensure Sinatra has a deterministic environment value.
ENV["RACK_ENV"] ||= ENV["SINATRA_ENV"] || "development"

database_url = ENV["DATABASE_URL"].to_s.strip
if database_url.empty?
  config_path = File.expand_path("./database.yml", __dir__)
  yaml = ERB.new(File.read(config_path)).result
  db_config = YAML.safe_load(yaml, aliases: true)
  ActiveRecord::Base.establish_connection(db_config.fetch(ENV["RACK_ENV"]))
else
  ActiveRecord::Base.establish_connection(database_url)
end

require_relative "../app/controllers/api/v1/base_controller"
require_relative "../app/controllers/api/v1/sessions_controller"
require_relative "../app/controllers/api/v1/drinks_controller"
require_relative "../app/controllers/api/v1/add_ons_controller"
require_relative "../app/controllers/api/v1/orders_controller"

require_relative "../app/models/admin"
require_relative "../app/models/drink"
require_relative "../app/models/add_on"
require_relative "../app/models/order"
require_relative "../app/models/order_item"
require_relative "../app/models/order_item_add_on"
