class CreateAdministrationStoredUrls < ActiveRecord::Migration
  def self.up
    create_table :stored_urls do |t|
      t.string :random_code
      t.string :user_auth_token
      t.integer :merchant_package_id
      t.string :url_string
      t.datetime :expiry
      t.timestamps
    end
  end

  def self.down
    drop_table :stored_urls
  end
end
