class Administration::MerchantOffering < ActiveRecord::Base
  belongs_to :offerings
  belongs_to :merchants
  
end
