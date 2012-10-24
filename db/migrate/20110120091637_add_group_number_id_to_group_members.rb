class AddGroupNumberIdToGroupMembers < ActiveRecord::Migration
  def self.up
    add_column :group_members, :group_number_id, :integer
  end

  def self.down
    remove_column :group_members, :group_number_id
  end
end
