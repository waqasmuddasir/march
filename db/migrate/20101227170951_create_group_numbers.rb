class CreateGroupNumbers < ActiveRecord::Migration
  def self.up
    create_table :group_numbers do |t|
      t.string :group_name
      t.string :phone_number

      t.timestamps
    end
  end

  def self.down
    drop_table :group_numbers
  end
end
