class AddPackageCode < ActiveRecord::Migration
  def self.up
     add_column :merchant_packages, :verification_code, :string
  end

  def self.down
     remove_column :merchant_packages, :verification_code
  end
end
