class AddPackageIdToUserGroup < ActiveRecord::Migration
  def self.up
    add_column :user_groups, :package_id, :integer
  end

  def self.down
    remove_column :user_groups, :package_id
  end
end
