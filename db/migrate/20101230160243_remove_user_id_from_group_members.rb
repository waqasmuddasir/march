class RemoveUserIdFromGroupMembers < ActiveRecord::Migration
  def self.up
    remove_column :group_members, :user_id
  end

  def self.down
    add_column :group_members, :user_id, :integer
  end
end
