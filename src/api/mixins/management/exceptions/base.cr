module API::Mixins::Management::Exceptions
  class Base < ::Exception
    property options : Hash(String, String | Int32)

    def initialize(message, **options)
      @options = options.to_h.as(Hash(String, String | Int32))
      super(message)
    end

    def headers
      @options.fetch("headers", {} of String => String | Int32)
    end

    def status
      @options.fetch("status")
    end
  end
end
