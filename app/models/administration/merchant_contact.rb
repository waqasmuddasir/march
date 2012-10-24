class Administration::MerchantContact < ActiveRecord::Base
  belongs_to :merchants
  belongs_to :contacts
end
