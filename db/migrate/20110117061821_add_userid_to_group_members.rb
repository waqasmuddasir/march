class AddUseridToGroupMembers < ActiveRecord::Migration
  def self.up
    add_column :group_members, :host_user_id, :integer
  end

  def self.down
    remove_column :group_members, :host_user_id
  end
end
