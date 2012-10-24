class CreateAdministrationStoredSignupUrls < ActiveRecord::Migration
  def self.up
    create_table :stored_signup_urls do |t|
      t.string :random_code
      t.integer :merchant_package_id
      t.integer :group_member_id
      t.string :url_string
      t.datetime :expiry
      t.timestamps
    end
  end

  def self.down
    drop_table :stored_signup_urls
  end
end
