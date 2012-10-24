xml = Builder::XmlMarkup.new
xml.instruct! 
xml.response{ 
    xml.status(@message.status)
    xml.code(@message.code)
    xml.detail(@message.detail)
    
      if !@offering.nil?
        
          xml.offering do
           xml.id(@offering.id)
            xml.title(@offering.title)
            xml.description(HTMLEntities.decode_entities(@offering.description))
            if(@offering.merchant_packages && @offering.merchant_packages.count > 0)
              xml.packages do
                @offering.merchant_packages.each do |package|
                  xml.package do
                    xml.id(package.id)
                    xml.title(package.title)
                    xml.description(package.description)
                    xml.start_date(package.start_date)
                    xml.end_date(package.end_date)
                    xml.created_at(package.created_at)
                    xml.updated_at(package.updated_at)
                  end
                end
              end
            end
            xml.created_at(@offering.created_at)
            xml.updated_at(@offering.updated_at)
          end
        
      end
    
}