module API::Admin::Broadcasts
  class Update < ApiAction
    param id : Int32
    param url : String
    param title : String
    param state : String

    put "/api/admin/broadcasts" do
      broadcast = Broadcast::BaseQuery.find(id)

      SaveBroadcast.update!(broadcast, url: url, title: title, state: state)

      json 200, status: 200
    end
  end
end
