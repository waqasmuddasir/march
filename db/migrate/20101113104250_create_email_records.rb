class CreateEmailRecords < ActiveRecord::Migration
  def self.up
    create_table :email_records do |t|
      t.string :sender
      t.string :recipient
      t.string :subject
      t.text :body
      t.integer :merchant_package_id
      t.integer :email_type

      t.timestamps
    end
  end

  def self.down
    drop_table :email_records
  end
end
