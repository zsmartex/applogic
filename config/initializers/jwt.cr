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
  property jwt : Hash(String, String)?
end
