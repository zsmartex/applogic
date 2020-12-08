module API::Public::Notifications
  class Get < ApiAction
    get "/api/public/banners" do
      broadcasts = Broadcast::BaseQuery.new.state("active").results.map(&.for_public)

      json broadcasts, status: 200
    end
  end
end
