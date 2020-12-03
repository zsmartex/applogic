module API::Resource::Documents
  class Get < ApiAction
    get "/api/resource/documents" do
      begin
        document = Document::BaseQuery.new
          .member_id(current_user.id)
          .state.in(["pending", "active"])
          .first

        json document.for_global, status: 201
      rescue e : Avram::RecordNotFoundError
        json nil, status: 200
      end
    end

  end
end
