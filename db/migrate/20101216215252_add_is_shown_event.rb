class AddIsShownEvent < ActiveRecord::Migration
    def self.up
    add_column :event_logs, :is_shown ,:boolean, :default => false
  end

  def self.down
    remove_column :event_logs, :is_shown
  end
end
