module API::Admin::Banners
  class Update < ApiAction
    param id : Int32
    param url : String
    param state : String

    put "/api/admin/banners" do
      banner = Banner::BaseQuery.find(id)

      SaveBanner.update!(banner.reload, url: url, state: state)

      json 200, status: 200
    end
  end
end
