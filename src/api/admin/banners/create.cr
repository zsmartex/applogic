module API::Admin::Banners
  class Create < ApiAction
    param url : String

    post "/api/admin/banners" do
      form_params = params.from_multipart.last
      uuid = UUID.random

      file_content = File.read(form_params["upload"].tempfile.path)

      File.write(filename: "#{ENV["BANNERS_LOCATION"]}/#{uuid}.png", content: file_content)

      Banner.create(
        uuid: uuid,
        url: url
      )

      json 201, status: 201
    end
  end
end
