module API::Public::Banners
  class Index < ApiAction
    get "/api/public/banners/preview/:uuid" do
      begin
        banner = Banner::BaseQuery.new
          .uuid(UUID.new(uuid))
          .first

        file path: "#{ENV["BANNERS_LOCATION"]}/#{banner.uuid}.png", content_type: "image/png", disposition: "inline", status: 200
      rescue
        json({ errors: ["public.banners.not_found"] }, status: 404)
      end
    end
  end
end
