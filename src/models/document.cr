require "base64"

class Document < BaseModel
  with_timestamps

  mapping(
    id:                           Primary32,
    member_id:                    Int64,
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
end
