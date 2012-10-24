class CreatePotentialUserEmailRecords < ActiveRecord::Migration
  def self.up
    create_table :potential_user_email_records do |t|
      t.integer :potential_user_id
      t.integer :email_record_id

      t.timestamps
    end
  end

  def self.down
    drop_table :potential_user_email_records
  end
end
