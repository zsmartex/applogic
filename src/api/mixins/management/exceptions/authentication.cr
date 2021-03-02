require "./base"

module API::Mixins::Management::Exceptions
  class Authentication < Base
    def status
      @options.fetch("status", 401)
    end
  end
end
