xml = Builder::XmlMarkup.new
xml.instruct! 
xml.response{ 
    xml.status(@message.status)
    xml.code(@message.code)
    xml.detail(@message.detail)
    xml.merchants do
      if !@merchants.nil?      
        @merchants.each do |merchant|
          xml.merchant do
            xml.id(merchant.id)
            xml.name(merchant.name)
            xml.detail(merchant.detail)
            xml.address(merchant.address)
            xml.country(merchant.country)
            xml.city(merchant.city)
            xml.phone(merchant.phone)
            xml.merchant_category  do
              xml.id(merchant.merchant_category.id)
              xml.name(merchant.merchant_category.name)
              xml.description(merchant.merchant_category.description)
            end            
            xml.created_at(merchant.created_at)
            xml.updated_at(merchant.updated_at)
          end
        end        
      end
    end
}