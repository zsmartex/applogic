require "action-controller"
require "./exception_handlers"
require "./helpers"
require "./auth/**"

module API::V2
  abstract class Base < ActionController::Base
    include V2::ExceptionHandlers
    include V2::Auth::Middleware
    include V2::Helpers

    def render_json(status = 200, content = Nop)
      render status: status, json: content
    end

    def render_text(status = 200, content = Nop)
      render status: status, text: content
    end

    def render_image(status = 200, content = Nop)
      response.content_type = "image/jpeg"

      render status: 200, binary: content
    end

  end
end
