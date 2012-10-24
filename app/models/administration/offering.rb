class Administration::Offering < ActiveRecord::Base
  has_many :merchant_offerings, :dependent => :destroy
  has_many :merchant_packages
  validates_presence_of :title
  validates_presence_of :description

  def add_offering_merchants(merchants)
    if merchants != nil
      self.delete_offering_merchants
      merchants.each do |merchant|
        merch = Administration::MerchantOffering.new(merchant)
        self.merchant_offerings << merch
      end
    end
  end
  def delete_offering_merchants
    Administration::MerchantOffering.delete_all(:offering_id => self.id)
  end
end
