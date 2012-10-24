class AddInstructionColumnToPackage < ActiveRecord::Migration
  def self.up
    add_column :merchant_packages, :redemption_instructions, :text
  end

  def self.down
    remove_column :merchant_packages, :redemption_instructions
  end
end
