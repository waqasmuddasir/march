class CreateAdministrationRedeemedPackages < ActiveRecord::Migration
  def self.up
    create_table :redeemed_packages do |t|
      t.integer :merchant_package_id
      t.integer :user_id
      t.datetime :start_time
      t.boolean :is_completed, :default => false
      t.integer :verification_code

      t.timestamps
    end
  end

  def self.down
    drop_table :redeemed_packages
  end
end
