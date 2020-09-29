module API::V2
  module ExceptionHandlers
    def error!(options : NamedTuple(errors: Array(String)), code : Int32)
      render_json status: code, content: options
    end
  end
end
