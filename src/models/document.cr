require "jwt-multisig"
require "base64"
require "crest"
require "json"

class Label
  include JSON::Serializable

  property key : String
  property value : String
  property scope : String
  property description : String?
  property created_at : Time
  property updated_at : Time
end

class Document < BaseModel
  with_timestamps

  STATES = %w[pending active rejected]

  mapping(
    id:                           Primary32,
    member_id:                    Int32,
    first_name:                   String,
    last_name:                    String,
    country:                      String,
    doc_type:                     String,
    doc_number:                   String,
    state:                        { type: String, default: "pending" },
    front_upload_file_path:       { type: String, default: "" },
    back_upload_file_path:        { type: String, default: "" },
    in_hand_upload_file_path:     { type: String, default: "" },
    created_at:                   Time?,
    updated_at:                   Time?
  )

  validates_inclusion :state, in: STATES

  after_commit :create_or_update_label, on: :save

  def member
    Member.find_by!(id: member_id)
  end

  def to_json
    {
      id:                         id,
      member_id:                  member_id,
      first_name:                 Base64.decode_string(first_name),
      last_name:                  Base64.decode_string(last_name),
      country:                    country,
      doc_type:                   doc_type,
      doc_number:                 doc_number,
      state:                      state,
      front_upload_file_path:     front_upload_file_path,
      back_upload_file_path:      back_upload_file_path,
      in_hand_upload_file_path:   in_hand_upload_file_path,
      created_at:                 created_at,
      updated_at:                 updated_at
    }
  end

  def for_global
    {
      id:                         id,
      first_name:                 Base64.decode_string(first_name),
      last_name:                  Base64.decode_string(last_name),
      country:                    country,
      doc_type:                   doc_type,
      doc_number:                 doc_number,
      state:                      state,
      created_at:                 created_at,
      updated_at:                 updated_at
    }
  end

  def create_or_update_label
    response = HTTP::Client.post(
      "http://barong:8001/api/v2/management/labels/list",
      headers: HTTP::Headers{ "Content-Type" => "application/json" },
      body: generate_jwt_management({
        :user_uid => member.uid
      })
    )

    labels = Array(Label).from_json(response.body)
    document_label = labels.find { |label| label.key == "document" }

    if document_label.nil?
      HTTP::Client.post(
        "http://barong:8001/api/v2/management/labels",
        headers: HTTP::Headers{ "Content-Type" => "application/json" },
        body: generate_jwt_management(
          {
            :user_uid => member.uid,
            :key => "document",
            :value => "pending"
          }
        )
      )
    end

    if state == "active" || state == "rejected"
      HTTP::Client.put(
        "http://barong:8001/api/v2/management/labels",
        headers: HTTP::Headers{ "Content-Type" => "application/json" },
        body: generate_jwt_management(
          {
            :user_uid => member.uid,
            :key => "document",
            :value => state == "active" ? "verified" : "rejected"
          }
        )
      )
    end

  end
end
