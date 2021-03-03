module API::Management::Users::Verify
  class Get < ApiAction
    include API::Mixins::Management::JWTAuthenticationMiddleware
    before require_jwt

    m_param email : String

    post "/api/management/users/verify" do
      @settings["scope"] = "write_codes"

      code = Code::BaseQuery.new.email(email).first?

      # error!({ errors: ["management.users.verify.code_exist"] }, 422) if code
      Code.create(type: "email", email: email)

      json 201, status: 201
    end

  end
end
