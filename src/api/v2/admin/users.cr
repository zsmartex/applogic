module API::V2::Admin
  class Users < API::V2::Base
    base "api/v2/admin/users"

    get "/documents" do
      return unless current_user.role == "admin"

      documents = Member
                    .find_by!(uid: params["uid"])
                    .documents
                    .tap { |q| q.where(first_name: params["first_name"]) if params["first_name"]? }
                    .tap { |q| q.where(first_name: params["last_name"]) if params["last_name"]? }
                    .tap { |q| q.where(first_name: params["country"]) if params["country"]? }
                    .tap { |q| q.where(first_name: params["doc_type"]) if params["doc_type"]? }
                    .tap { |q| q.where(first_name: params["state"]) if params["state"]? }
                    .limit(
                      params.fetch("limit", "100").to_i
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