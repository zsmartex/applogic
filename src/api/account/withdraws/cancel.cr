require "./helpers"

module API::Account::Withdraws
  class Cancel < ApiAction
    include API::Account::Withdraws::Helpers

    param tid : String
    param confirmation_code : String?
    param otp_code : String?

    post "/api/account/withdraws/cancel" do
      if otp_code.nil? && confirmation_code.nil?
        return error!({ errors: [
          "account.withdraw.invalid_confirmation_code",
          "account.withdraw.invalid_otp_code"
        ] }, 422)
      end

      sign_otp(user_uid: current_user.uid, otp_code: otp_code.not_nil!, tid: tid) unless otp_code.nil?

      unless confirmation_code.nil?
        code = Code::BaseQuery.new
          .type("withdraw")
          .email(current_user.email)
          .first?

        return error!({ errors: ["account.withdraws.invalid_code"] }, 422) if code.nil?
        return error!({ errors: ["account.withdraws.out_of_attempts"] }, 422) if code.attempts >= 3
        return error!({ errors: ["account.withdraws.invalid_code"] }, 422) if code.validated_at

        unless confirmation_code == code.confirmation_code
          SaveCode.update!(code, attempts: code.attempts + 1)
          return error!({ errors: ["account.withdraws.invalid_code"] }, 422)
        end
        
        return error!({ errors: ["account.withdraws.code_expired"] }, 422) if Time.local > code.expired_at

        SaveCode.update!(code, validated_at: Time.local)
      end

      perform_action_withdraw(tid: tid, action: "cancel")

      json get_withdraw(tid: tid), status: 201
    rescue e : HTTP::Client::Response::Exception
      case e.response.body
      when { error: "Account has not enabled 2FA" }.to_json
        error!({ errors: ["account.withdraw.otp_not_enabled"] }, 422)
      when { error: "OTP code is invalid" }.to_json
        error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
      when { error: "This code was already used. Wait until the next time period" }.to_json
        error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
      else
        error!({ errors: ["account.withdraw.cancel_error"] }, 422)
      end
    end

  end
end
