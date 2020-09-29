module API::V2
  module Helpers
    def headers
      request.headers
    end

    @body : JSON::Any?

    def body : JSON::Any
      return @body.not_nil! if @body
      if request.body
        body_payload = request.body.not_nil!.gets_to_end
        if body_payload.size
          begin
            @body = JSON.parse(body_payload)
          rescue
            @body = JSON.parse("{}")
          end
        end
      end

      return JSON.parse("{}") if @body.nil?
      @body.not_nil!
    end

  end
end
