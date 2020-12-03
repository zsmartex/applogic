class CreateMembers::V20201129084728 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Member) do
      primary_key id : Int32

      add uid : String
      add email : String, unique: true
      add level : Int32
      add role : String
      add state : String
      add referral_uid : String?

      add_timestamps
    end
  end

  def rollback
    drop table_for(Member)
  end
end
