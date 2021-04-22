require "./helpers"

module API::Account::Withdraws
  class GenerateCode < ApiAction
    include API::Account::Withdraws::Helpers

    param tid : String

    post "/api/account/withdraws/generate_code" do
      begin
        withdraw = get_withdraw(tid: tid)

        raise "Couldn't find record." unless withdraw.uid == current_user.uid
        raise "Couldn't find record." unless withdraw.state == "prepared"
      rescue
        return error!({ errors: ["account.withdraw.withdraw_invalid"] }, 422)
      end

      code = Code::BaseQuery.new.type("withdraw").email(current_user.email).first
      SaveCode.update!(code, confirmation_code: rand.to_s[2, 6], attempts: 0, expired_at: Time.local + 30.minutes, validated_at: nil)

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

      json 201, status: 201
    end
  end
end
