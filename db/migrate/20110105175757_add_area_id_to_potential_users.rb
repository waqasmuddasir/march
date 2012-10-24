class AddAreaIdToPotentialUsers < ActiveRecord::Migration
  def self.up
    add_column :potential_users, :area_id, :integer
  end

  def self.down
     remove_column :potential_users, :area_id
  end
end
