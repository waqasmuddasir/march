class CreateGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :group_members do |t|
      t.integer :user_id
      t.integer :user_group_id
      t.boolean :is_active, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :group_members
  end
end
