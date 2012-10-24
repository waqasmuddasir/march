class Administration::Merchant < ActiveRecord::Base
  belongs_to :merchant_category
  has_many :merchant_contacts
  has_many :merchant_offerings, :dependent => :destroy
  validates_presence_of :name
  validate :custom_validations
  validates_presence_of :detail
  validates_presence_of :address
  validates_presence_of :country
  validates_presence_of :city
  validates_presence_of :phone
  geocoded_by :location
  after_validation :fetch_coordinates

  def custom_validations
    if self.name
      temp = self.name.capitalize.strip
      merchant = Administration::Merchant.find(:first,:conditions => {:name => temp})
      if merchant && merchant.id != self.id
         errors.add_to_base("Name is already taken.")
      end      
    end
  end
  def location
    [address, city,country].compact.join(', ')
  end

end
