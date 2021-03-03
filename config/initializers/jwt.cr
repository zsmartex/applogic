require "json"
require "yaml"
require "openssl"
require "base64"
require "openssl_ext"

class ManagementApi
  include JSON::Serializable
  
  class Keychain
    include JSON::Serializable
  
    property algorithm : String
    property value : String
  
    def value
      OpenSSL::PKey::RSA.new(Base64.decode_string(@value))
    end
  
    def private?
      value.private?
    end
  end

  property keychain : Hash(String, Keychain)
  property scopes : Hash(String, NamedTuple(mandatory_signers: Array(String), permitted_signers: Array(String)))
  property jwt : Hash(String, String)
end

ManagementApi.from_json(YAML.parse(File.read("./config/management_api.yml")).to_json).tap do |x|
  x.keychain.each do |id, key|
    if key.private?
      raise ArgumentError.new("keychain." + id.to_s + " was set to private key, however it should be public (in config/management_api.yml).")
    end
  end

  x.scopes.values.each do |scope|
    ["permitted_signers", "mandatory_signers"].each do |list|
      if list == "mandatory_signers" && scope[list].not_nil!.empty?
        raise ArgumentError.new(
          "scopes." + scope.to_s + "." + list.to_s + " is empty, 'however it should contain at least one value (in config/management_api.yml)."
        )
      end
    end
  end

  API::Mixins::Management::JWTAuthenticationMiddleware.security_configuration = x
end
