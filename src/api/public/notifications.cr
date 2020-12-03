module API::Public::Notifications
  class Get < ApiAction
    get "/api/public/banners" do
      notifications = Notification::BaseQuery.new.state("active").results.map(&.for_public)

      json notifications, status: 200
    end
  end
end
