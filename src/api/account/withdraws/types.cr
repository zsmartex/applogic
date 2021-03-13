class WithdrawFromManagement
  include JSON::Serializable

  property tid : Int32
  property uid : String
  property currency_id : String
  property type : String
  property amount : String
  property fee : String
  property rid : String
  property state : String
  property txid : String
  property created_at : String

  def to_json
    {
      tid: tid,
      uid: uid,
      currency_id: currency_id,
      amount: amount,
      fee: fee,
      rid: rid,
      state: state,
      txid: txid,
      created_at: created_at,
    }.to_json
  end
end
