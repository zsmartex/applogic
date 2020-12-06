module API::Admin::Documents
  class Index < ApiAction
    get "/api/admin/documents/:id" do
      document = Document::BaseQuery.find(id).to_json

      json document, status: 200
    end
  end
end
