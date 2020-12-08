module API::Admin::Broadcasts
  class Create < ApiAction
    param url : String
    param title : String

    post "/api/admin/broadcasts" do
      Broadcast.create(
        url: url,
        title: title
      )

      json 201, status: 201
    end
  end
end
