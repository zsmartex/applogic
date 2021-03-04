module API::Management::Users::Verify
  class Update < ApiAction
    @scope = "write_codes"

    before require_jwt

    m_param email : String

    put "/api/management/users/verify" do
      begin
        response = HTTP::Client.post(
          "http://barong:8001/api/v2/management/users/get",
          headers: HTTP::Headers{ "Content-Type" => "application/json" },
          body: generate_jwt_management(
            {
              :email => email
            }
          )
        )

        user = BarongUser.from_json(response.body)
      rescue
        return error!({ errors: ["management.users.verify.user_not_exist"] }, 422)
      end

      code = Code::BaseQuery.new.email(email).first

      SaveCode.update!(code, confirmation_code: rand.to_s[2, 7], expired_at: Time.local + 15.minutes)

      EventAPI.notify(
        "system.user.email.confirmation.code",
        {
          :record => {
            :user => user,
            :domain => ENV["APPLOGIC_DOMAIN"],
            :code => code.reload.confirmation_code
          }
        }
      )

      json 200, status: 200
    end

  end
end
