class ChangeCodeType::V20210313030426 < Avram::Migrator::Migration::V1
  def migrate
    # Read more on migrations
    # https://www.luckyframework.org/guides/database/migrations
    #
    alter table_for(Code) do
      change_type email : String
      remove :phone
    end
  end

  def rollback
    alter table_for(Code) do
      change_type email : String
      add phone : String?
    end
  end
end
