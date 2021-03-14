class MakeCodeEmailRequired::V20210314194227 < Avram::Migrator::Migration::V1
  def migrate
    make_required :codes, :email
  end

  def rollback
    alter table_for(Code) do
      change_type email : String
    end
  end
end
