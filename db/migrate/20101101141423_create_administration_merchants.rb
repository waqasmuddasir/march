class CreateAdministrationMerchants < ActiveRecord::Migration
  def self.up
    create_table :merchants do |t|
      t.string :name
      t.text :detail
      t.text :address
      t.string :country
      t.string :city
      t.string :phone
      t.integer :merchant_category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :merchants
  end
end
