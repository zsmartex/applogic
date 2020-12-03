module API::Admin::Documents
  class Get < ApiAction
    param uid : String?
    param state : String?
    param country : String?
    param doc_type : String?
    param doc_number : String?
    param page : Int32 = 1
    param limit : Int32 = 100

    get "/api/admin/documents" do
      begin
        documents = Document::BaseQuery.new
          .tap { |q| q.member_id(Member::BaseQuery.new.uid(uid.not_nil!).first.id) if uid }
          .tap { |q| q.state(state.not_nil!) if state }
          .tap { |q| q.country(country.not_nil!) if country }
          .tap { |q| q.doc_type(doc_type.not_nil!) if doc_type }
          .tap { |q| q.doc_number(doc_number.not_nil!) if doc_number }
          .offset((page - 1) * limit)
          .limit(limit)
          .results.map(&.to_json)

        json documents, status: 200
      rescue
        json JSON.parse("[]"), status: 200
      end
    end
  end
end
