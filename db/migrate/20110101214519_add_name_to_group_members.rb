class AddNameToGroupMembers < ActiveRecord::Migration
  def self.up
     add_column :group_members, :name, :string
  end

  def self.down
    remove_column :group_members, :name
  end
end
