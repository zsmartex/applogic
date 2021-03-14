require "./helpers"

module API::Management::Users::Verify
  class Create < ApiAction
    include API::Management::Users::Verify::Helpers

    @scope = "write_codes"

    before require_jwt

    m_param type : String
    m_param email : String
    m_param event_name : String

    post "/api/management/users/verify" do
      user = get_user(email)
      code = Code::BaseQuery.new.type(type).email(user.email).first?

      return error!({ errors: ["management.users.verify.code_exist"] }, 422) if code
      code = Code.create(type: type, email: user.email, confirmation_code: rand.to_s[2, 6], expired_at: Time.local + 30.minutes)

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
