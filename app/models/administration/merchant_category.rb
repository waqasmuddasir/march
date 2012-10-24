class Administration::MerchantCategory < ActiveRecord::Base
 has_many :merchants

  validates_presence_of :name
  
end
