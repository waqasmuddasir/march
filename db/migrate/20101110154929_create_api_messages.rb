class CreateApiMessages < ActiveRecord::Migration
  def self.up
    create_table :api_messages do |t|
      t.string :status
      t.integer :code
      t.string :detail

      t.timestamps
    end
    
  end

  def self.down
    drop_table :api_messages
  end
end
