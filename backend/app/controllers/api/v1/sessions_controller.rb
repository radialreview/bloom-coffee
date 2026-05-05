module Api
  module V1
    class SessionsController < BaseController
      post "/login" do
        payload = parsed_body
        email = payload["email"].to_s.strip
        password = payload["password"].to_s
        admin = Admin.find_by(email: email)

        unless admin&.authenticate(password)
          halt 401, json(error: "Invalid email or password.")
        end

        token = JWT.encode({ sub: admin.email, exp: Time.now.to_i + 60 * 60 * 8 }, jwt_secret, "HS256")
        json(token: token, admin: { email: admin.email })
      end

      get "/session" do
        admin = authenticate_admin!
        json(authenticated: true, admin: { email: admin.email })
      end

      post "/logout" do
        authenticate_admin!
        json(message: "Logged out.")
      end
    end
  end
end
