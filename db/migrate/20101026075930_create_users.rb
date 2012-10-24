class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100, :default => '', :null => true
      t.column :email,                     :string, :limit => 150
      t.column :first_name,                :string, :limit => 100
      t.column :middle_name,               :string, :limit => 100
      t.column :last_name,                 :string, :limit => 100
      t.column :company,                   :string, :limit => 100, :default => '', :null => true
      t.column :address,                   :string, :limit => 200
      t.column :county,                    :string, :limit => 100
      t.column :post_code,                 :string, :limit => 20
      t.column :mobile,                    :string, :limit => 20
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime


    end
    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :mobile, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
