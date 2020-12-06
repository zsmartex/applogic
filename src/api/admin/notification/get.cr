module API::Admin::Notifications
  class Get < ApiAction
    get "/api/admin/notifications" do
      notifications = Notification::BaseQuery.new.state("active").results.map(&.to_json)

      json notifications, status: 200
    end
  end
end
