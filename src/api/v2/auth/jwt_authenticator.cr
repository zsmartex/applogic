require "base64"
require "jwt"

module API::V2
  module Auth
    class JWTAuthenticator
      property token : String

      def initialize(@token : String)
      end

      def authenticate
        JWT.decode(@token, Base64.decode_string(ENV["JWT_PUBLIC_KEY"]), JWT::Algorithm::RS256).first
      end
    end
  end
end
