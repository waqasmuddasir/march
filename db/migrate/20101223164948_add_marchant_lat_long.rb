class AddMarchantLatLong < ActiveRecord::Migration
  def self.up
    add_column :merchants, :latitude ,  :float
    add_column :merchants, :longitude,  :float
  end

  def self.down
     remove_column :merchants, :latitude
     remove_column :merchants, :longitude
  end
end
