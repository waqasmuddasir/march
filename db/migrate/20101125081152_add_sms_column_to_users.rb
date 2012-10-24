class AddSmsColumnToUsers < ActiveRecord::Migration
  def self.up
        add_column :users, :sms_notification, :boolean
  end

  def self.down
        remove_column :users, :sms_notification
  end
end
