module API::Admin::Notifications
  class Create < ApiAction
    param url : String
    param title : String

    post "/api/admin/notifications" do
      Notification.create(
        url: url,
        title: title
      )

      json 201, status: 201
    end
  end
end
