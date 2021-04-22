class WithdrawFromManagement
  include JSON::Serializable

  property tid : String
  property uid : String
  property currency : String
  property type : String
  property amount : String
  property fee : String
  property rid : String
  property state : String
  property blockchain_txid : String?

  property created_at : Time

  def to_json
    {
      tid: tid,
      currency: currency,
      amount: amount,
      fee: fee,
      rid: rid,
      state: state,
      blockchain_txid: blockchain_txid,
      created_at: created_at,
    }.to_json
  end
end
