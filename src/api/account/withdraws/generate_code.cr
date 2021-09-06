require "./helpers"

module API::Account::Withdraws
  class GenerateCode < ApiAction
    include API::Account::Withdraws::Helpers

    param currency : String
    param amount : Float64
    
    post "/api/account/withdraws/generate_code" do
      code = Code::BaseQuery.new.type("withdraw").email(current_user.email).first?

      if code.nil?
        code = Code.create(type: "withdraw", email: current_user.email, confirmation_code: rand.to_s[2, 6], expired_at: Time.local + 30.minutes)
      else
        SaveCode.update!(code, confirmation_code: rand.to_s[2, 6], attempts: 0, expired_at: Time.local + 30.minutes, validated_at: nil)
      end

      EventAPI.notify(
        "system.withdraw.confirmation.code",
        {
          :record => {
            :amount => amount,
            :currency => currency,
            :user => current_user.to_json,
            :domain => ENV["APPLOGIC_DOMAIN"],
            :code => code.reload.confirmation_code
          }
        }
      )

      json 201, status: 201
    end
  end
end
