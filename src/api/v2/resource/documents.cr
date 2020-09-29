require "uuid"
require "base64"

module API::V2::Resource
  class Documents < API::V2::Base
    base "api/v2/resource"

    post "/documents" do
      begin
        ["first_name", "last_name", "country", "doc_type", "doc_number"].each do |name|
          return error!({ errors: ["resource.documents.missing_#{name}"] }, 422) unless params[name]?
        end

        uploads = files.not_nil!
        ["front_upload", "back_upload", "in_hand_upload"].each do |name|
          if uploads[name]?.nil?
            return error!({ errors: ["resource.documents.missing_#{name}"] }, 422)
          end
          file = uploads[name].first

          unless file.filename.to_s.ends_with?(/\.(jpe?g|png)$/i)
            return error!({ errors: ["resource.documents.#{name}_invalid"] }, 422)
          end
        end

        document = Document.create(
          member_id: current_user.id,
          first_name: Base64.encode(params["first_name"]),
          last_name: Base64.encode(params["last_name"]),
          country: params["country"],
          doc_type: params["doc_type"],
          doc_number: params["doc_number"]
        )

        ["front_upload", "back_upload", "in_hand_upload"].each do |name|
          file = uploads[name].first
          file_content = file.body.gets_to_end
          file_name = "#{UUID.random}.#{file.filename}"

          File.write(filename: "#{ENV["DOCUMENTS_LOCATION"]}/#{file_name}", content: file_content)

          document.set_attributes({ "#{name}_file_path" => "#{file_name}" })
        end
        document.save!

        render_json status: 200, content: 200
      rescue e
        puts e
        error!({ errors: ["resource.documents.create_error"] }, 422)
      end
    end
  end
end
