class Administration::Contact < ActiveRecord::Base

   validates_presence_of :first_name
   validates_presence_of :last_name
   validates :email,:presence   => true,                   
                    :format     => { :with => Authentication.email_regex, :message => Authentication.bad_email_message },
                    :length     => { :within => 6..100 }
   validates_uniqueness_of :email
   has_many :merchant_contacts

  def add_contact_merchants(merchants)
    if merchants != nil
    self.delete_contact_merchants
    
    merchants.each do |merchant|
      mer = Administration::MerchantContact.new(merchant)
      self.merchant_contacts << mer
    end
    end

  end
  def delete_contact_merchants()
   Administration::MerchantContact.delete_all(:contact_id => self.id)
  end
   
end
