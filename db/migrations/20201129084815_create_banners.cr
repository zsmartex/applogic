class CreateBanners::V20201129084815 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Banner) do
      primary_key id : Int32

      add uuid : UUID
      add url : String
      add state : String, default: "active"

      add_timestamps
    end
  end

  def rollback
    drop table_for(Banner)
  end
end
