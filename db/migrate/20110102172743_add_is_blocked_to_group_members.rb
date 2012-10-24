class AddIsBlockedToGroupMembers < ActiveRecord::Migration
  def self.up
    add_column :group_members, :is_blocked, :boolean, :default => false
  end

  def self.down
    remove_column :group_members,:is_blocked
  end
end
