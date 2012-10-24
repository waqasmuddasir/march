class CreateGroupMemberLeaves < ActiveRecord::Migration
  def self.up
    create_table :group_member_leaves do |t|
      t.integer :user_group_id
      t.string  :mobile
      t.string  :name
      t.integer :package_id
      t.integer :host_user_id
      t.integer :group_number_id
      t.boolean :is_active
      t.boolean :is_blocked
      t.timestamps
    end
  end

  def self.down
    drop_table :group_member_leaves
  end
end
