class CreateDocuments::V20201129084833 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Document) do
      primary_key id : Int32

      add member_id : Int32
      add first_name : String
      add last_name : String
      add country : String
      add doc_type : String
      add doc_number : String
      add state : String, default: "pending"
      add front_upload_file_name : String
      add back_upload_file_name : String
      add in_hand_upload_file_name : String

      add_timestamps
    end
  end

  def rollback
    drop table_for(Document)
  end
end
