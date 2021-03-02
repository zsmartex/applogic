require "./exceptions/**"

module API::Mixins::Management
  module JWTAuthenticationMiddleware
    def require_jwt
      return continue unless request.path.includes?("/api/management")
      return continue if request.path == "/api/management/swagger"

      return json("Only POST and PUT verbs are allowed.", 405) unless ["POST", "PUT", "DELETE"].includes?(request.method)
      return json("Query parameters are not allowed.", 400) unless request.query_params.empty?
      return json("Only JSON body is accepted.", 400) unless request.headers["content-type"] == "application/json"

      payload = check_jwt!(jwt)

      continue
    end

    def check_jwt!(jwt)
      
    end

  end
end
