module API::Management::Users::Verify
  class Create < ApiAction
    @scope = "write_codes"

    before require_jwt

    m_param email : String
    m_param event_name : String

    post "/api/management/users/verify" do
      begin
        response = HTTP::Client.post(
          "http://barong:8001/api/v2/management/users/get",
          headers: HTTP::Headers{ "Content-Type" => "application/json" },
          body: generate_jwt_management({
            :email => email
          })
        )

        user = BarongUser.from_json(response.body)
      rescue
        return error!({ errors: ["management.users.verify.user_not_exist"] }, 422)
      end

      code = Code::BaseQuery.new.email(user.email).first?

      return error!({ errors: ["management.users.verify.code_exist"] }, 422) if code
      code = Code.create(type: "email", email: user.email, confirmation_code: rand.to_s[2, 6], expired_at: Time.local + 30.minutes)

      EventAPI.notify(
        event_name,
        {
          :record => {
            :user => user,
            :domain => ENV["APPLOGIC_DOMAIN"],
            :code => code.confirmation_code
          }
        }
      )

      json 201, status: 201
    end

  end
end
