class CreateSignupUrls < ActiveRecord::Migration
  def self.up
    create_table :signup_urls do |t|
      t.integer :user_id
      t.integer :stored_signup_url_id

      t.timestamps
    end
  end

  def self.down
    drop_table :signup_urls
  end
end
