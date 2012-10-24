xml = Builder::XmlMarkup.new
xml.instruct! 
xml.response{ 
    xml.status(@message.status)
    xml.code(@message.code)
    xml.detail(@message.detail)
    if !@user.nil?
      xml.user do
        xml.name(@user.name)
        xml.email(@user.email)
        xml.auth_token(@user.auth_token)
      end
    end
}