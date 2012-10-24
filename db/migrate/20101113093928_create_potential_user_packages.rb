class CreatePotentialUserPackages < ActiveRecord::Migration
 
  def self.up
    create_table :potential_user_packages do |t|
      t.integer :potential_user_id
      t.integer :merchant_package_id
      t.boolean :is_subscribed

      t.timestamps
    end
  end

  def self.down
    drop_table :potential_user_packages
  end
end
