require "./helpers"

module API::Management::Users::Verify
  class Update < ApiAction
    include API::Management::Users::Verify::Helpers

    @scope = "write_codes"

    before require_jwt

    m_param type : String
    m_param email : String
    m_param reissue : Bool? = false
    m_param attempts : Int32?
    m_param validated : Bool? = false
    m_param event_name : String

    put "/api/management/users/verify" do
      user = get_user(email)
      code = Code::BaseQuery.new.type(type).email(email).first?

      return error!({ errors: ["management.users.verify.code_not_exist"] }, 422) if code.nil?

      if attempts
        SaveCode.update!(code, attempts: attempts.not_nil!)
      elsif validated
        SaveCode.update!(code, validated_at: Time.local)
      elsif reissue
        SaveCode.update!(code, confirmation_code: rand.to_s[2, 6], attempts: 0, expired_at: Time.local + 30.minutes, validated_at: nil)

        EventAPI.notify(
          event_name,
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
