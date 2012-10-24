class CreateAdministrationMerchantPackages < ActiveRecord::Migration
  def self.up
    create_table :merchant_packages do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :merchant_id
      t.integer :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :merchant_packages
  end
end
