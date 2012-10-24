class CreateAdministrationContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :company
      t.text :address
      t.string :country
      t.string :city
      t.string :phone
      t.string :mobile

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
