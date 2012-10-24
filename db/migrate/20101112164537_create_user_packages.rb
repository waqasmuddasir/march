class CreateUserPackages < ActiveRecord::Migration
  def self.up
    create_table :user_packages do |t|
      t.integer :user_id
      t.integer :merchant_package_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_packages
  end
end
