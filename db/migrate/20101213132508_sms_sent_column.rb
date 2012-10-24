class SmsSentColumn < ActiveRecord::Migration
  def self.up
     add_column :user_packages, :sms_sent, :boolean
  end

  def self.down
    drop_column :user_packages, :sms_sent
  end
end
