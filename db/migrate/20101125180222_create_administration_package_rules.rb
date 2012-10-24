class CreateAdministrationPackageRules < ActiveRecord::Migration
  def self.up
    create_table :package_rules do |t|
      t.boolean :is_all_day
      t.datetime :start_time
      t.datetime :end_time
      t.string :rule
      t.integer :merchant_package_id
      t.timestamps
    end
  end

  def self.down
    drop_table :package_rules
  end
end
