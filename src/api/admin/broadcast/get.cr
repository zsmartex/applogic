module API::Admin::Broadcasts
  class Get < ApiAction
    get "/api/admin/broadcasts" do
      broadcasts = Broadcast::BaseQuery.new.state("active").results.map(&.to_json)

      json broadcasts, status: 200
    end
  end
end
