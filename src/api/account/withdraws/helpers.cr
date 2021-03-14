module API::Account::Withdraws::Helpers
  def get_withdraw(tid : Int32)
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

  def create_withdraw(address : String, currency : String, amount : Float64)
    response = api_client(
      method: "post",
      url: "http://peatio:8000/api/v2/management/withdraws/new",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :uid => current_user.uid,
        :rid => address,
        :currency => currency,
        :amount => amount,
      })
    )

    WithdrawFromManagement.from_json(response.body)
  end

  def perform_action_withdraw(tid : Int32, action : String)
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

    api_client(
      "post",
      url: "http://peatio:8000/api/v2/management/withdraws/action",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :jwt => jwt,
        :otp_code => otp_code,
        :user_uid => user_uid,
      })
    )
  end
end
