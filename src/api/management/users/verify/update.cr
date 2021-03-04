module API::Management::Users::Verify
  class Update < ApiAction
    @scope = "write_codes"

    before require_jwt

    m_param email : String

    put "/api/management/users/verify" do
      code = Code::BaseQuery.new.email(email).first

      SaveCode.update!(code, confirmation_code: rand.to_s[2, 7], expired_at: Time.local + 15.minutes)

      json 200, status: 200
    end

  end
end
