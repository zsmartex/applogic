module API::Account::Withdraws::Helpers
  def get_withdraw(tid : String)
    response = api_client(
      method: "post",
      url: "http://peatio:8000/api/v2/management/withdraws/get",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :tid => tid,
      })
    )

    WithdrawFromManagement.from_json(response.body)
  end

  def create_withdraw(blockchain_key : String?, address : String?, beneficiary_id : String?, currency : String, amount : Float64)
    if address.nil?
      response = api_client(
        method: "post",
        url: "http://peatio:8000/api/v2/management/withdraws/new",
        headers: HTTP::Headers{ "Content-Type" => "application/json" },
        body: generate_jwt_management({
          :uid => current_user.uid,
          :beneficiary_id => beneficiary_id,
          :currency => currency,
          :amount => amount,
        })
      )
    else
      response = api_client(
        method: "post",
        url: "http://peatio:8000/api/v2/management/withdraws/new",
        headers: HTTP::Headers{ "Content-Type" => "application/json" },
        body: generate_jwt_management({
          :uid => current_user.uid,
          :blockchain_key => blockchain_key,
          :rid => address,
          :currency => currency,
          :amount => amount,
        })
      )
    end

    WithdrawFromManagement.from_json(response.body)
  end

  def perform_action_withdraw(tid : String, action : String)
    response = api_client(
      method: "put",
      url: "http://peatio:8000/api/v2/management/withdraws/action",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :tid => tid,
        :action => action,
      })
    )

    WithdrawFromManagement.from_json(response.body)
  end

  def sign_otp(user_uid : String, otp_code : String, **params)
    jwt = generate_jwt_management(params.merge(user_uid: user_uid))
    Finex.logger.error { JSON.parse(jwt) }

    api_client(
      "post",
      url: "http://barong:8001/api/v2/management/otp/sign",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :jwt => JSON.parse(jwt),
        :otp_code => otp_code,
        :user_uid => user_uid,
      })
    )
  end
end
