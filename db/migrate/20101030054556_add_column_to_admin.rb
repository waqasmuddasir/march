class AddColumnToAdmin < ActiveRecord::Migration
  def self.up
    add_column :admins, :is_super, :boolean, :default => false
  end

  def self.down
    remove_column :admins, :is_super
  end
end
