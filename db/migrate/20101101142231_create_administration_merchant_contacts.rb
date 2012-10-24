class CreateAdministrationMerchantContacts < ActiveRecord::Migration
  def self.up
    create_table :merchant_contacts do |t|
      t.integer :merchant_id
      t.integer :contact_id

      t.timestamps
    end
  end

  def self.down
    drop_table :merchant_contacts
  end
end
