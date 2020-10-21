class Member < BaseModel
  with_timestamps

  ROLES = %w[superadmin admin manager accountant compliance support technical member broker trader maker]
  ADMIN_ROLES = %w[superadmin admin accountant compliance support technical manager]

  mapping(
    id:               Primary32,
    uid:              String,
    email:            String,
    level:            { type: Int32, default: 0 },
    role:             { type: String, default: "member" },
    state:            { type: String, default: "pending" },
    referral_uid:     String?,
    created_at:       Time?,
    updated_at:       Time?
  )

  validates_length :uid, maximum: 32
  validates_length :referral_uid, maximum: 32, allow_blank: true
  validates_presence :email
  validates_uniqueness :email
  validates_numericality :level, greater_than_or_equal_to: 0
  validates_inclusion :role, in: ROLES

  scope :enabled, -> { where(state: "active") }

  before_validation :downcase_email

  def documents
    Document.where(member_id: id)
  end

  # Create Member object from payload
  # == Example payload
  # {
  #   :iss=>"barong",
  #   :sub=>"session",
  #   :aud=>["finex"],
  #   :email=>"admin@barong.io",
  #   :referral_uid=>"ID26V2D14DB8",
  #   :uid=>"ID24C2D87DB5",
  #   :role=>"admin",
  #   :state=>"active",
  #   :level=>"3",
  #   :iat=>1540824073,
  #   :exp=>1540824078,
  #   :jti=>"4f3226e554fa513a"
  # }
  def self.from_payload(params)
    member = Member.find_by(uid: params["uid"].to_s, email: params["email"].to_s)
    unless member
      member = Member.create(
        uid: params["uid"].to_s,
        email: params["email"].to_s,
      )
    end
    member.level = params["level"].to_s.to_i
    member.role = params["role"].to_s
    member.state = params["state"].to_s
    member.referral_uid = params["referral_uid"].to_s if params["referral_uid"]?

    member.save! if member.changed?
    member
  end

  private def downcase_email
    self.email = email.downcase
  end
end
