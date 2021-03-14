require "./helpers"

module API::Account::Withdraws
  class Cancel < ApiAction
    include API::Account::Withdraws::Helpers

    param tid : Int32
    param otp_code : String

    post "/api/account/withdraws/cancel" do
      begin
        sign_otp(user_uid: current_user.uid, otp_code: otp_code, tid: tid)

        perform_action_withdraw(tid: tid, action: "cancel")
      rescue e : HTTP::Client::Response::Exception
        case e.response.body
        when "Account has not enabled 2FA"
          return error!({ errors: ["account.withdraw.otp_not_enabled"] }, 422)
        when "OTP code is invalid"
          return error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
        else
          return error!({ errors: ["account.withdraw.cancel_error"] }, 422)
        end
      end

      json 201, status: 201
    end
  end
end
