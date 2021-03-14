require "./helpers"

module API::Account::Withdraws
  class Create < ApiAction
    include API::Account::Withdraws::Helpers

    param otp_code : String
    param address : String
    param currency : String
    param amount : Float64

    post "/api/account/withdraws" do
      begin
        sign_otp(user_uid: current_user.uid, address: address, currency: currency, amount: amount, otp_code: otp_code)

        withdraw = create_withdraw(address: address, currency: currency, amount: amount)
      rescue e : HTTP::Client::Response::Exception
        case e.response.body
        when "Account has not enabled 2FA"
          return error!({ errors: ["account.withdraw.otp_not_enabled"] }, 422)
        when "OTP code is invalid"
          return error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
        when "Failed to create withdraw!"
          return error!({ errors: ["account.withdraw.create_error"] }, 422)
        else
          return error!({ errors: ["account.withdraw.insufficient_balance"] }, 422)
        end
      end

      code = Code.create(type: "withdraw", email: current_user.email, confirmation_code: rand.to_s[2, 6], expired_at: Time.local + 30.minutes)

      EventAPI.notify(
        "withdraw.confirmation.code",
        {
          :record => {
            :withdraw => withdraw,
            :user => current_user.to_json,
            :domain => ENV["APPLOGIC_DOMAIN"],
            :code => code.confirmation_code
          }
        }
      )

      json 201, status: 201
    end
  end
end
