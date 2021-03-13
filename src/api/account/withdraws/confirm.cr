require "./helpers"

module API::Account::Withdraws
  class Confirm < ApiAction
    include API::Account::Withdraws::Helpers

    param tid : Int32
    param confirmation_code : String

    post "/api/account/withdraws/confirm" do
      begin
        perform_action_withdraw(tid: tid, action: "process")
      rescue
        return error!({ errors: ["account.withdraw.confirm_error"] }, 422)
      end

      code = Code::BaseQuery.new
        .type("withdraw")
        .email(current_user.email)
        .first

      if code.validated_at
        return error!({ errors: ["account.withdraws.invalid_code"] }, 422)
      end

      unless confirmation_code == code.confirmation_code
        SaveCode.update!(code, attempts: code.attempts + 1)
        return error!({ errors: ["account.withdraws.out_of_attempts"] }, 422) if code.attempts >= 3
      end
      
      if code.expired_at > Time.local
        return error!({ errors: ["account.withdraws.code_expired"] }, 422)
      end

      SaveCode.update!(code, validated_at: Time.local)

      json 201, status: 201
    end
  end
end
