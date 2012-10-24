class MerchantPackageImages < ActiveRecord::Migration
  def self.up
     create_table :merchant_package_images do |t|
      t.integer :size
      t.string  :content_type
      t.string  :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string  :thumbnail
      t.integer :merchant_package_id
      t.timestamps
    end
  end

  def self.down
     drop_table :merchant_package_images
  end
end
