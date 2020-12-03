class CreateNotifications::V20201129084849 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Notification) do
      primary_key id : Int32

      add url : String
      add title : String
      add state : String, default: "active"

      add_timestamps
    end
  end

  def rollback
    drop table_for(Notification)
  end
end
