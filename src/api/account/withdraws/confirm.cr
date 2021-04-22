require "./helpers"

module API::Account::Withdraws
  class Confirm < ApiAction
    include API::Account::Withdraws::Helpers

    param tid : String
    param confirmation_code : String

    post "/api/account/withdraws/confirm" do
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

      begin
        withdraw = get_withdraw(tid: tid)

        raise "Couldn't find record." unless withdraw.uid == current_user.uid
        raise "Couldn't find record." unless withdraw.state == "prepared"
      rescue
        return error!({ errors: ["account.withdraw.withdraw_invalid"] }, 422)
      end

      begin
        perform_action_withdraw(tid: tid, action: "process")
      rescue
        return error!({ errors: ["account.withdraw.confirm_error"] }, 422)
      end

      json get_withdraw(tid: tid), status: 201
    end
  end
end
