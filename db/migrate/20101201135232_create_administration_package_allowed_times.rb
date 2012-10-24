class CreateAdministrationPackageAllowedTimes < ActiveRecord::Migration
  def self.up
    create_table :package_allowed_times do |t|
      t.integer :package_rule_id
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :package_allowed_times
  end
end
