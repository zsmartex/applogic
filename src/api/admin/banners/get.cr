module API::Admin::Banners
  class Get < ApiAction
    get "/api/admin/banners" do
      banners = Banner::BaseQuery.new.state("active").results.map(&.to_json)

      json banners, status: 200
    end
  end
end
