module API::Resource::Documents
  class Create < ApiAction
    param first_name : String
    param last_name : String
    param country : String
    param doc_type : String
    param doc_number : String

    post "/api/resource/documents" do
      form_params = params.from_multipart.last
      files = Hash(String, NamedTuple(name: String, file: File)).new
      ["front_upload", "back_upload", "in_hand_upload"].each do |name|
        file_content = File.read(form_params[name].tempfile.path)
        file_name = "#{UUID.random}.#{form_params[name].filename}"
        file_path = "#{ENV["DOCUMENTS_LOCATION"]}/#{file_name}"

        File.write(filename: file_path, content: file_content)
        files[name] = { name: file_name, file: File.new(file_path) }
      end

      Document.create(
        member_id: current_user.id,
        first_name: first_name,
        last_name: last_name,
        country: country,
        doc_type: doc_type,
        doc_number: doc_number,
        front_upload_file_name: files["front_upload"]["name"],
        back_upload_file_name: files["back_upload"]["name"],
        in_hand_upload_file_name: files["in_hand_upload"]["name"]
      )

      json 201, status: 201
    end

  end
end
