require "jwt"

module API::Mixins::Auth
  def current_user
    token = request.headers["authorization"].lchop("Bearer ")
    jwt_decoded = JWT.decode(token, Base64.decode_string(ENV["JWT_PUBLIC_KEY"]), JWT::Algorithm::RS256).first

    Member.from_payload(jwt_decoded)
  end
end
