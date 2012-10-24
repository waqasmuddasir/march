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
            xml.verification_code(@package.verification_code)
            xml.created_at(@package.created_at)
            xml.updated_at(@package.updated_at)
            xml.is_valid(@is_valid.to_s)
            if !@redeem_id.nil?
              xml.redeem_id(@redeem_id)
            end
             if !@next_day.nil?
              xml.next_day(@next_day.strftime('%A, %b %d, %Y'))
            end
            if !@package.merchant_package_image.nil?
              xml.package_image("http://#{ApplicationController::SITE_URL}"+@package.merchant_package_image.public_filename(:medium))
            end
            if !@package.offering.merchant_offerings.nil?
                  xml.merchants do
                    @package.offering.merchant_offerings.each do |m|
                      merch = Administration::Merchant.find(m.merchant_id)
                      if !merch.nil?
                        xml.merchant do
                          xml.name(merch.name)
                        end
                      end
                    end
                  end
                end       
          end
        
      end
    
}