require "bundler/setup"
Bundler.require(:default)

require "dotenv/load"
require "sinatra/base"
require "sinatra/json"
require "sinatra/activerecord"
require "jwt"
require "bcrypt"
require "time"

set :database_file, File.expand_path("./database.yml", __dir__)

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
