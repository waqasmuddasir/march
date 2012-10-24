class RemoveIndexFrimUser < ActiveRecord::Migration
  def self.up
    remove_index :users, :mobile
  end

  def self.down
    add_index :users, :mobile, :unique => true
  end
end
