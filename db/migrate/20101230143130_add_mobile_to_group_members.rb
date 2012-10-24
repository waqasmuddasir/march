class AddMobileToGroupMembers < ActiveRecord::Migration
   def self.up
    add_column :group_members, :mobile, :string
  end

  def self.down
    remove_column :group_members, :mobile
  end
end
