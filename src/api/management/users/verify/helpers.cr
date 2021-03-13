module API::Management::Users::Verify::Helpers
  def get_user(email : String)
    response = api_client(
      method: "post",
      url: "http://barong:8001/api/v2/management/users/get",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :email => email
      })
    )

    BarongUser.from_json(response.body)
  end
end