class BarongUser
  include JSON::Serializable

  property uid : String
  property email : String
  property role : String
  property level : Int32
  property otp : Bool
  property state : String
  property data : String?

  def to_json
    {
      uid: uid,
      email: email,
      role: role,
      data: data,
      level: level,
      otp: otp,
      state: state,
    }.to_json
  end

  def for_user
    
  end
end
