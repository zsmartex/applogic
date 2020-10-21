class CreateAllTables < Jennifer::Migration::Base
  def up
    create_table(:members) do |t|
      t.string :uid, { :size => 32, :null => false }
      t.string :email, { :size => 255, :null => false }
      t.integer :level, { :null => false }
      t.string :role, { :size => 32,:null => false }
      t.string :state, { :size => 16, :null => false}
      t.string :referral_uid, { :size => 32 }
      t.timestamps
    end

    create_table(:documents) do |t|
      t.integer :member_id, { :null => false }
      t.string :first_name, { :null => false }
      t.string :last_name, { :null => false }
      t.string :country, { :null => false }
      t.string :doc_type, { :null => false }
      t.string :doc_number, { :null => false }
      t.string :state, { :size => 16, :null => false }
      t.string :front_upload_file_path, { :null => false }
      t.string :back_upload_file_path, { :null => false }
      t.string :in_hand_upload_file_path, { :null => false }
      t.timestamps
    end
  end

  def down
    drop_table(:members)
    drop_table(:documents)
  end
end
