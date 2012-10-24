class CreatePotentialUsers < ActiveRecord::Migration
    def self.up
    create_table "potential_users" do |t|
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100
      t.column :email,                     :string, :limit => 150, :null => false
      t.column :first_name,                :string, :limit => 100
      t.column :middle_name,               :string, :limit => 100
      t.column :last_name,                 :string, :limit => 100
      t.column :company,                   :string, :limit => 100
      t.column :address,                   :string, :limit => 200
      t.column :county,                    :string, :limit => 100
      t.column :post_code,                 :string, :limit => 20
      t.column :mobile,                    :string, :limit => 20
      t.column :is_registered,             :boolean, :default=>false
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
        
    end

    #add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    #add_index :users, :mobile, :unique => true
  end

  def self.down
    drop_table "potential_users"
  end
end
