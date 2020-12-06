module API::Admin::Documents
  class Preview < ApiAction
    get "/api/admin/documents/:id/preview/:type" do
      document = Document::BaseQuery.find(id)

      return json({ errors: ["admin.documents.image_not_found"] }, status: 404) unless %w[front_upload back_upload in_hand_upload].includes?(type)

      if type == "front_upload"
        file_content = document.front_upload
      elsif type == "back_upload"
        file_content = document.back_upload
      else
        file_content = document.in_hand_upload
      end

      file path: file_content, content_type: "image/png", disposition: "inline", status: 200
    end
  end
end
