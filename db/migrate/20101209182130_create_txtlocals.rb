class CreateTxtlocals < ActiveRecord::Migration
  def self.up
    create_table :txtlocals do |t|
      t.string :sms_type
      t.string :message_contents
      t.timestamps
    end
  end

  def self.down
    drop_table :txtlocals
  end
end
