module API::Admin::Banners
  class Update < ApiAction
    param url : String
    param state : String

    post "/api/admin/banners/:id" do
      banner = Banner::BaseQuery.find(id)

      SaveBanner.update!(banner.reload, url: url, state: state)

      json 200, status: 200
    end
  end
end
