xml = Builder::XmlMarkup.new
xml.instruct! 
xml.response{ 
    xml.status(@message.status)
    xml.code(@message.code)
    xml.detail(@message.detail)
    
      if !@package.nil?        
          xml.package do
           xml.id(@package.id)
            xml.title(@package.title)
            xml.description(HTMLEntities.decode_entities(@package.description))
            xml.start_date(@package.start_date)
            xml.end_date(@package.end_date)
            if @package.offering != nil
              xml.offering do
                xml.id(@package.offering.id)
                xml.title(@package.offering.title)
                xml.description(HTMLEntities.decode_entities(@package.offering.description))
                xml.created_at(@package.offering.created_at)
                xml.updated_at(@package.offering.updated_at)
              end
            end
            
            xml.created_at(@package.created_at)
            xml.updated_at(@package.updated_at)
            xml.is_valid(@is_valid)
            if !@redeem_id.nil?
              xml.redeem_id(@redeem_id)
            end
             if !@redeemed_package.nil?
              xml.redeemed_at(@redeemed_package.start_time.strftime('%d/%m/%y at %I:%M %P'))
            end
             if !@package.merchant_package_image.nil?
              xml.package_image("http://#{ApplicationController::SITE_URL}"+@package.merchant_package_image.public_filename(:medium))
            end
          end
        
      end
    
}