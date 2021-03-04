module API::Resource::Users
  class Verify < ApiAction
    post "/api/resource/users/verify/:code" do
      q_code = Code::BaseQuery.new
        .type("email")
        .email(current_user.email)
        .first

      attempts = q_code.attempts

      unless code == q_code.confirmation_code
        SaveCode.update!(q_code, attempts: attempts + 1)
        return error!({ errors: ["resource.users.verify.out_of_attempts"] }, 422) if attempts >= 5

        json 200, status: 200
      else
        SaveCode.update!(q_code, attempts: attempts + 1, validated_at: Time.local)

        json 200, status: 200
      end
    end

  end
end
