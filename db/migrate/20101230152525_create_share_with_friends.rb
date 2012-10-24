class CreateShareWithFriends < ActiveRecord::Migration
  def self.up
    create_table :share_with_friends do |t|
      t.string :sender_name
      t.string :sender_email
      t.string :friend_name
      t.string :friend_email
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :share_with_friends
  end
end
