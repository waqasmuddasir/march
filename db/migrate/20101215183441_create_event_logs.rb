class CreateEventLogs < ActiveRecord::Migration
  def self.up
    create_table :event_logs do |t|
      t.string  :event_class
      t.integer :event_action
      t.string  :event_body
      t.integer :user_id
      t.integer :merchant_package_id

      t.timestamps
    end
  end

  def self.down
    drop_table :event_logs
  end
end
