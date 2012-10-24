xml = Builder::XmlMarkup.new
xml.instruct! 
xml.response{ 
    xml.status(@message.status)
    xml.code(@message.code)
    xml.detail(@message.detail)
    xml.packages do
      if !@packages.nil?
        @packages.each do |key,package|
          xml.package do
            xml.id(package.id)
            xml.title(package.title)
            xml.description(HTMLEntities.decode_entities(package.description))
            xml.start_date(package.start_date)
            xml.end_date(package.end_date)
            xml.created_at(package.created_at)
            xml.updated_at(package.updated_at)
          end
        end        
      end
    end
}