module API::Public::Banners
  class Get < ApiAction
    get "/api/public/banners" do
      banners = Banner::BaseQuery.new.state("active").results.map(&.for_public)

      json banners, status: 200
    end
  end
end
