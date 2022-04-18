require "./helpers"

module API::Account::Withdraws
  class Create < ApiAction
    include API::Account::Withdraws::Helpers

    param otp_code : String
    param blockchain_key : String?
    param address : String?
    param beneficiary_id : String?
    param currency : String
    param amount : Float64
    param confirmation_code : String

    post "/api/account/withdraws" do
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

      unless address.nil?
        return error!({ errors: ["account.withdraw.invaild_blockchain_key"] }, 422) if blockchain_key.nil?
      end

      unless blockchain_key.nil?
        return error!({ errors: ["account.withdraw.invaild_address"] }, 422) if address.nil?
      end

      sign_otp(user_uid: current_user.uid, address: address, beneficiary_id: beneficiary_id, currency: currency, amount: amount, otp_code: otp_code)

      withdraw = create_withdraw(blockchain_key: blockchain_key, address: address, beneficiary_id: beneficiary_id, currency: currency, amount: amount)

      SaveCode.update!(code, validated_at: Time.local)

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
      Log.error { e.response.body }
      case e.response.body
      when { error: "Account has not enabled 2FA" }.to_json
        error!({ errors: ["account.withdraw.otp_not_enabled"] }, 422)
      when { error: "OTP code is invalid" }.to_json
        error!({ errors: ["account.withdraw.otp_code_invalid"] }, 422)
      when { error: "management.beneficiary.doesnt_exist" }.to_json
        error!({ errors: ["account.withdraw.invalid_beneficiary"] }, 422)
      when { error: "management.beneficiary.invalid_state_for_withdrawal" }.to_json
        error!({ errors: ["account.withdraw.invalid_beneficiary"] }, 422)
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
