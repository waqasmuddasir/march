class AddCodeColumnToPackage < ActiveRecord::Migration
  def self.up
    add_column :merchant_packages, :access_code, :string
  end

  def self.down
    remove_column :merchant_packages, :access_code
  end
end
