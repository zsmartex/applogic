module API::Management::Users::Verify
  class Update < ApiAction
    include API::Mixins::Management::JWTAuthenticationMiddleware
    before require_jwt

    post "/api/management/users/verify" do
      @settings["scope"] = "write_codes"

      json 201, status: 201
    end

  end
end
