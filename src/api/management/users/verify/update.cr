module API::Management::Users::Verify
  class Update < ApiAction
    @scope = "write_codes"

    before require_jwt

    m_param email : String
    m_param reissue : Bool? = false
    m_param attempts : Int32?
    m_param validated : Bool? = false

    put "/api/management/users/verify" do
      begin
        response = HTTP::Client.post(
          "http://barong:8001/api/v2/management/users/get",
          headers: HTTP::Headers{ "Content-Type" => "application/json" },
          body: generate_jwt_management({
            :email => email
          })
        )

        user = BarongUser.from_json(response.body)
      rescue e
        report_exception(e)
        return error!({ errors: ["management.users.verify.user_not_exist"] }, 422)
      end

      code = Code::BaseQuery.new.email(email).first

      if attempts
        SaveCode.update!(code, attempts: attempts.not_nil!)
      elsif validated
        SaveCode.update!(code, validated_at: Time.local)
      elsif reissue
        SaveCode.update!(code, confirmation_code: rand.to_s[2, 6], attempts: 0, expired_at: Time.local + 30.minutes)

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
      end

      json 200, status: 200
    end

  end
end
