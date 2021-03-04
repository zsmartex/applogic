module API::Management::Users::Verify
  class Create < ApiAction
    @scope = "write_codes"

    before require_jwt

    m_param email : String

    post "/api/management/users/verify" do
      code = Code::BaseQuery.new.email(email).first?

      return error!({ errors: ["management.users.verify.code_exist"] }, 422) if code
      code = Code.create(type: "email", email: email, confirmation_code: rand.to_s[2, 7], expired_at: Time.local + 15.minutes)

      EventApi.notify(
        "system.user.email.confirmation.code",
        record: {
          user: { email },
          domain: domain,
          code: code.reload.confirmation_code
        }
      )

      json 201, status: 201
    end

  end
end
