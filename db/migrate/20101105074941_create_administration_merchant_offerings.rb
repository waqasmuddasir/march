class CreateAdministrationMerchantOfferings < ActiveRecord::Migration
  def self.up
    create_table :merchant_offerings do |t|
      t.integer :merchant_id
      t.integer :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :merchant_offerings
  end
end
