module API::Management::Users::Verify
  class Get < ApiAction
    @scope = "read_codes"

    before require_jwt

    m_param type : String
    m_param email : String

    post "/api/management/users/verify/get" do
      code = Code::BaseQuery.new.type(type).email(email).first?

      return error!({ errors: ["management.users.verify.code_not_exist"] }, 422) if code.nil?

      json code.to_json, status: 200
    end

  end
end
