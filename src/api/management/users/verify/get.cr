module API::Management::Users::Verify
  class Get < ApiAction

    get "/api/management/users/verify" do
      json 200, status: 201
    end

  end
end
