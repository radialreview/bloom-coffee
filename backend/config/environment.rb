require "bundler/setup"
require "dotenv/load"

require "sinatra/base"
require "jwt"
require "bcrypt"
require "time"
require "sinatra/json"
require "sinatra/activerecord"
require "rack/cors"

# Ensure Sinatra has a deterministic environment value.
ENV["RACK_ENV"] ||= ENV["SINATRA_ENV"] || "development"

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
