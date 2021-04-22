require "./helpers"

module API::Account::Withdraws
  class Create < ApiAction
    include API::Account::Withdraws::Helpers

    param otp_code : String
    param address : String
    param currency : String
    param amount : Float64

    post "/api/account/withdraws" do
      sign_otp(user_uid: current_user.uid, address: address, currency: currency, amount: amount, otp_code: otp_code)

      withdraw = create_withdraw(address: address, currency: currency, amount: amount)

      code = Code::BaseQuery.new.type("withdraw").email(current_user.email).first?

      if code.nil?
        code = Code.create(type: "withdraw", email: current_user.email, confirmation_code: rand.to_s[2, 6], expired_at: Time.local + 30.minutes)
      else
        SaveCode.update!(code, confirmation_code: rand.to_s[2, 6], expired_at: Time.local + 30.minutes, validated_at: nil)
      end

      EventAPI.notify(
        "system.withdraw.confirmation.code",
        {
          :record => {
            :withdraw => withdraw,
            :user => current_user.to_json,
            :domain => ENV["APPLOGIC_DOMAIN"],
            :code => code.reload.confirmation_code
          }
        }
      )

      json withdraw, status: 201
    rescue e : HTTP::Client::Response::Exception
      Finex.logger.error { e.response.body }
      case e.response.body
      when { error: "Account has not enabled 2FA" }.to_json
        error!({ errors: ["account.withdraw.otp_not_enabled"] }, 422)
      when { error: "OTP code is invalid" }.to_json
        error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
      when { error: "This code was already used. Wait until the next time period" }.to_json
        error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
      when { errors: ["Failed to create withdraw!"] }.to_json
        error!({ errors: ["account.withdraw.create_error"] }, 422)
      else
        error!({ errors: ["account.withdraw.insufficient_balance"] }, 422)
      end
    rescue
      error!({ errors: ["account.withdraw.create_error"] }, 422)
    end

  end
end
