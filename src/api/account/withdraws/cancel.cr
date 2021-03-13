require "./helpers"

module API::Account::Withdraws
  class Cancel < ApiAction
    include API::Account::Withdraws::Helpers

    param tid : Int32
    param otp_code : String

    post "/api/account/withdraws/cancel" do
      code = Code::BaseQuery.new
        .type("withdraw")
        .email(current_user.email)
        .first

      begin
        perform_action_withdraw(tid: tid, action: "cancel")
      rescue
        return error!({ errors: ["account.withdraw.cancel_error"] }, 422)
      end

      SaveCode.update!(code, validated_at: Time.local)

      json 201, status: 201
    end
  end
end
