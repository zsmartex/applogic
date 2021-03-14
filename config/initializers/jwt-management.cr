def generate_jwt_management(data : Hash | NamedTuple | Nil = {} of String => String)
  JWT::Multisig.generate_jwt(
    {
      data: data,
      iat:  Time.local.to_unix,
      exp:  Time.local.to_unix + 60,
      jti:  Random::Secure.hex(12),
      iss:  "applogic"
    },
    {
      :applogic => Base64.decode_string(ENV["JWT_PRIVATE_KEY"])
    },
    {
      :applogic => JWT::Algorithm::RS256
    }
  ).to_json
end
