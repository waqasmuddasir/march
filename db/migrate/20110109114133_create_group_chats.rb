class CreateGroupChats < ActiveRecord::Migration
  def self.up
    create_table :group_chats do |t|
      t.string :sender
      t.string :contents
      t.string :in_number
      t.string :user_group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :group_chats
  end
end
