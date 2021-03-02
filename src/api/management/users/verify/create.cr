module API::Management::Users::Verify
  class Get < ApiAction

    param email : String
    param phone : String

    post "/api/management/users/verify" do
      member = Member::BaseQuery.new.email(email).first
      code = Code::BaseQuery.new.email(email).first?

      # error!({ errors: ["management.users.verify.code_exist"] }, 422) if code
      Code.create(member_id: member.id, type: "email", email: email)

      json 201, status: 201
    end

  end
end
