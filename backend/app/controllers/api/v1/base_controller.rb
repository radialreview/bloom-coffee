module Api
  module V1
    class BaseController < Sinatra::Base
      configure do
        set :show_exceptions, false
        set :raise_errors, false
        set :environment, ENV.fetch("RACK_ENV", "development").to_sym
      end

      helpers Sinatra::JSON

      before do
        content_type :json
      end

      options "*" do
        200
      end

      not_found do
        json(error: "Not found")
      end

      error ActiveRecord::RecordNotFound do
        halt 404, json(error: "Not found")
      end

      error ActiveRecord::RecordInvalid do
        details = env["sinatra.error"].record.errors.full_messages.join(", ")
        halt 422, json(error: details)
      end

      error JSON::ParserError do
        halt 400, json(error: "Invalid JSON body.")
      end

      error do
        halt 500, json(error: "Unexpected server error")
      end

      helpers do
        def parsed_body
          raw = request.body.read
          return {} if raw.to_s.strip.empty?

          JSON.parse(raw)
        end

        def jwt_secret
          ENV.fetch("JWT_SECRET", "dev-secret-change-me")
        end

        def current_admin
          header = request.env["HTTP_AUTHORIZATION"].to_s
          token = header.start_with?("Bearer ") ? header.split(" ", 2).last : nil
          halt 401, json(error: "Unauthorized") unless token

          payload, = JWT.decode(token, jwt_secret, true, algorithm: "HS256")
          @current_admin ||= Admin.find_by!(email: payload["sub"])
        rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
          halt 401, json(error: "Unauthorized")
        end

        def authenticate_admin!
          current_admin
        end
      end
    end
  end
end
