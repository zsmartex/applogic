module API::Management::Users::Verify
  class Update < ApiAction

    post "/api/management/users/verify" do
      json 201, status: 201
    end

  end
end
