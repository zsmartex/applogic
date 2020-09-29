module API::V2::Admin
  class Documents < API::V2::Base
    base "api/v2/admin"

    get "/members/documents/:member_id", :member_id do
      return unless current_user.role == "admin"

      documents = Member
                    .find!(params["member_id"])
                    .documents
                    .limit(
                      params.fetch("limit", "100").to_i * params.fetch("page", "1").to_i
                    )

      render_json status: 200, content: documents.to_a.map { |document| document.to_json }
    end

    get "/documents/:id", :id do
      return unless current_user.role == "admin"

      document = Document.find(params["id"])

      render_json status: 200, content: document.to_json
    end

    get "/documents/view/:file", :file do
      return unless current_user.role == "admin"

      file = File.read(filename: "#{ENV["DOCUMENTS_LOCATION"]}/#{params["file"]}")

      render_image status: 200, content: file
    end

    post "/documents/update" do
      return unless current_user.role == "admin"

      document = Document.find!(body["id"].to_s)
      document.state = body["state"].to_s
      document.save!

      render_json status: 200, content: document.to_json
    end

  end
end
