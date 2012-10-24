class AddPackageIdToGroupMembers < ActiveRecord::Migration
  def self.up
    add_column :group_members, :package_id, :integer
  end

  def self.down
    remove_column :group_members, :package_id
  end
end
