module API::Admin::Documents
  class Update < ApiAction
    param id : Int32
    param first_name : String
    param last_name : String
    param country : String
    param doc_type : String
    param doc_number : String
    param state : String

    post "/api/admin/documents" do
      document = Document::BaseQuery.find(id)

      SaveDocument.update!(document, first_name: first_name, last_name: last_name, country: country, doc_type: doc_type, doc_number: doc_number, state: state)

      json 200, status: 200
    end
  end
end
