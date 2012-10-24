
#This module will contain all utility functions to be used in the application

module Utils  

  # Takes a mobile number string as input
  # convert it according to uk number format
  #TODO just copy and past the code from users controller, see if it needs more checks
  def process_mobile_number(number)
    number = number.strip
    number.gsub(" ","")
    number.gsub("-","")
    number = number.last(10) if number.length>10
    "44#{number}"
  end

  # @url url of the server to which api call is to be sent
  # @options is a hash of the form
  # {:content_type=>content_type, :body=>body}


  def call_api(url, options={})
    url = URI.parse("#{url}")
    if options[:method] == :post
      request = Net::HTTP::Post.new(url.path)
    else
      request = Net::HTTP::Get.new(url.path)
    end

    unless options[:body].blank?
      request.body = options[:body]
    end
    unless options[:content_type].blank?
      request.content_type = options[:content_type]
    end
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    response
  end



def strip_mobile! mobile

    mobile = mobile_remove_extra_bits(mobile)
    mobile = mobile_add_code(mobile) if !mobile.nil?
    mobile = all_digits?(mobile) if !mobile.nil?
  return mobile
end


  def mobile_remove_extra_bits mobile
    mobile=mobile.gsub('+','')
    mobile=mobile.gsub(' ','')
    mobile=mobile.gsub("-","")
    mobile=mobile.gsub(")","")
    mobile=mobile.gsub("(","")
    mobile=mobile.gsub("<","")
    mobile=mobile.gsub(">","")
    return mobile
  end

  def mobile_add_code mobile
    if mobile.length>=10
      mobile=mobile.last(10)
      mobile="44"+mobile
    else
      return nil
    end
  end

  def all_digits? mobile
    if (mobile =~ /^[0-9]+$/)
      return mobile
    else
      return nil
    end
  end
end
