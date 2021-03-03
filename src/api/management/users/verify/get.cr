module API::Management::Users::Verify
  class Get < ApiAction
    include API::Mixins::Management::JWTAuthenticationMiddleware
    before require_jwt

    get "/api/management/users/verify" do
      @settings["scope"] = "read_codes"

      json 200, status: 200
    end

  end
end
