require "./jwt_authenticator"

module API::V2
  module Auth
    module Middleware
      def auth_by_jwt?
        headers.has_key?("authorization")
      end

      
      def authenticate!
        current_user
      end

      def current_user : Member
        jwt_decoded = Auth::JWTAuthenticator.new(headers["authorization"].lchop("Bearer ")).authenticate

        Member.from_payload(jwt_decoded)
      end
    end
  end
end
