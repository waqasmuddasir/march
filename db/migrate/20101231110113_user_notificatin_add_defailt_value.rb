class UserNotificatinAddDefailtValue < ActiveRecord::Migration
  def self.up
     change_column :users, :email_notification, :boolean, :default => false, :null => false
  end

  def self.down
    change_column :users, :email_notification, :boolean, :default => false, :null => false
  end
end
