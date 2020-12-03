module API::Admin::Notifications
  class Update < ApiAction
    param url : String
    param title : String
    param state : String

    delete "/api/admin/notifications/:id" do
      notification = Notification::BaseQuery.find(id)

      SaveNotification.update!(notification, url: url, title: title, state: state)

      json 200, status: 200
    end
  end
end
