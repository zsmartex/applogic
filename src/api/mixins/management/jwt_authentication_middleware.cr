require "./exceptions/**"

module API::Mixins::Management
  module JWTAuthenticationMiddleware
    property settings = Hash(String | JSON::Any, String | JSON::Any).new
    @@security_configuration : ManagementApi?

    def self.security_configuration=(value)
      @@security_configuration = value
    end

    def self.security_configuration
      @@security_configuration.not_nil!
    end

    def require_jwt
      return continue unless request.path.includes?("/api/management")
      return continue if request.path == "/api/management/swagger"

      return json("Only POST and PUT verbs are allowed.", 405) unless ["POST", "PUT", "DELETE"].includes?(request.method)
      return json("Query parameters are not allowed.", 400) unless request.query_params.empty?
      return json("Only JSON body is accepted.", 400) unless request.headers["content-type"] == "application/json"

      begin
        settings["payload"] = check_jwt!(JSON.parse(request.body.to_s))["data"]
      rescue e
        Finex.logger.error { "ManagementAPI check_jwt error: #{e.inspect}" }
        return json("Couldn't parse JWT.", 400)
      end

      continue
    end

    def check_jwt!(jwt)
      scope    = @@security_configuration.not_nil!.scopes[@settings["scope"]]
      keychain = @@security_configuration.not_nil!
                  .keychain
                  .select { |id, key| scope["permitted_signers"].includes?(id) }
                  .each_with_object({} of String => String) { |(k, v), memo| memo[k] = v.value.to_pem }
      result   = JWT::Multisig.verify_jwt(jwt, keychain)
      # unless 

      result["payload"]
    end

    # Access query and POST parameters
    #
    # When a query parameter or POST data is passed to an action, it is stored in
    # the params object. But accessing the param directly from the params object
    # isn't type safe. Enter `param`. It checks the given param's type and makes
    # it easily available inside the action.
    #
    # ```
    # class Posts::Index < BrowserAction
    #   param page : Int32?
    #
    #   route do
    #     plain_text "Posts - Page #{page || 1}"
    #   end
    # end
    # ```
    #
    # To generate a link with a param, use the `with` method:
    # `Posts::Index.with(10).path` which will generate `/posts?page=10`. Visiting
    # that path would render the above action like this:
    #
    # ```text
    # Posts - Page 10
    # ```
    #
    # This works behind the scenes by creating a `page` method in the action to
    # access the parameter.
    #
    # **Note:** Params can also have a default, but then their routes will not
    # include the parameter in the query string. Using the `with(10)` method for a
    # param like this:
    # `param page : Int32 = 1` will only generate `/posts`.
    #
    # These parameters are also typed. The path `/posts?page=ten` will raise a
    # `Lucky::InvalidParamError` error because `ten` is a String not an
    # Int32.
    #
    # Additionally, if the param is non-optional it will raise the
    # `Lucky::MissingParamError` error if the required param is absent
    # when making a request:
    #
    # ```
    # class UserConfirmations::New
    #   param token : String # this param is required!
    #
    #   route do
    #     # confirm the user with their `token`
    #   end
    # end
    # ```
    #
    # When visiting this page, the path _must_ contain the token parameter:
    # `/user_confirmations?token=abc123`
    macro m_param(type_declaration)
      {% PARAM_DECLARATIONS << type_declaration %}
      @@query_param_declarations << "{{ type_declaration.var }} : {{ type_declaration.type }}"

      def {{ type_declaration.var }} : {{ type_declaration.type }}
        {% is_nilable_type = type_declaration.type.is_a?(Union) %}
        {% type = is_nilable_type ? type_declaration.type.types.first : type_declaration.type %}

        val = @settings["payload"][{{ type_declaration.var.stringify }}]?

        if val.nil?
          default_or_nil = {{ type_declaration.value.is_a?(Nop) ? nil : type_declaration.value }}
          {% if is_nilable_type %}
            return default_or_nil
          {% else %}
            if default_or_nil.nil?
              raise Lucky::MissingParamError.new("{{ type_declaration.var.id }}")
            else
              return default_or_nil
            end
          {% end %}
        end

        result = {{ type }}::Lucky.parse(val)

        if result.is_a? {{ type }}::Lucky::SuccessfulCast
          result.value
        else
          raise Lucky::InvalidParamError.new(
            param_name: "{{ type_declaration.var.id }}",
            param_value: val.to_s,
            param_type: "{{ type }}"
          )
        end
      end
    end

  end
end
