def generate_jwt_management(data : Hash | NamedTuple | Nil = {} of String => String)
  JWT::Multisig.generate_jwt(
    {
      exp:  Time.local.to_unix + 60,
      data: data
    },
    {
      :applogic => Base64.decode_string(ENV["JWT_PRIVATE_KEY"])
    },
    {
      :applogic => JWT::Algorithm::RS256
    }
  ).to_json
end
