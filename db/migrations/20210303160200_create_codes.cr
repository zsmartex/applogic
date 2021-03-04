class CreateCode::V20210303160200 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Code) do
      primary_key id : Int32

      add type : String
      add email : String?
      add phone : String?
      add confirmation_code : String
      add attempts : Int32, default: 0
      add validated_at : Time?
      add expired_at : Time

      add_timestamps
    end
  end

  def rollback
    drop table_for(Code)
  end
end
