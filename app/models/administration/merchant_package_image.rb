class Administration::MerchantPackageImage < ActiveRecord::Base
 belongs_to :merchant_package
 
 has_attachment :content_type => :image, :resize_to => "500x240>",
                 :storage => :file_system,
                 :path_prefix => 'public/photos',
                 :max_size => 10.megabytes,
                 :thumbnails => {:medium => [300, 150]},
                 :processor => "Rmagick"
validates_as_attachment
end
