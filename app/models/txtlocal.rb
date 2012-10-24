class Txtlocal < ActiveRecord::Base

  REDEEM_LINK = "redeem_link"
  RESET_PASSWORD = "reset_password"
  GROUP_CHAT="group_chat"
  GROUP_INVITATION = "group_invitation"

  def self.find_or_create(message_contents)
    if self.find_by_sms_type(message_contents[:sms_type]).nil?
      self.new(message_contents).save
    end
  end

  def send_sms(number)
    api_response = ""
    result = deliver_sms(number,self.message_contents)
    result_json = JSON.parse result.body rescue nil
    if result_json.nil?
      api_response = "Credit not available"
    elsif !result_json["Error"].nil?
      api_response = result_json["Error"]
    elsif !result_json["ERROR"].nil?
      api_response = result_json["ERROR"]
    else
      api_response = "Link has been sent to "+number
    end
    api_response
  end

  def send_group_chat_sms(group_phone_number, mobile)
    api_response = ""
    #self.message_contents = CGI.escape(self.message_contents)
    result = deliver_group_sms(group_phone_number, mobile, self.message_contents)
    result_json = JSON.parse result.body rescue nil

    if result_json.nil?
      api_response = "Credit not available"
    elsif !result_json["Error"].nil?
      api_response = result_json["Error"]
    elsif !result_json["ERROR"].nil?
      api_response = result_json["ERROR"]
    else
      api_response = "Link has been sent to " + mobile
    end
    api_response
  end


  private
  TXTLOCAL_SETTINGS= YAML.load_file("#{Rails.root.to_s}/config/txtlocal.yml")
  API_URL = TXTLOCAL_SETTINGS["api_url"].to_s
  USER = TXTLOCAL_SETTINGS["username"].to_s
  PASSWORD = TXTLOCAL_SETTINGS["password"].to_s

  def deliver_sms(number,message_contents)
    #result = Net::HTTP.post_form(URI.parse('http://www.txtlocal.com/sendsmspost.php'),
     # {'json'=>'1', 'test'=>'0','message' => message_contents,"from"=>"Ultra","uname" => "#{USER}","pword"=>"#{PASSWORD}","selectednums" => "#{number}"})
    #result
    @sms="simple Ultra " + number +  message_contents


   
  end
  
  def deliver_group_sms(group_phone_number, mobile,message_contents )
    #result = Net::HTTP.post_form(URI.parse('http://www.txtlocal.com/sendsmspost.php'),
    #  {'json'=>'1', 'test'=>'0','message' => message_contents,"from"=>group_phone_number,"uname" => "#{USER}","pword"=>"#{PASSWORD}","selectednums" => "#{mobile}"})
  #result
    @sms=mobile + message_contents

  end
end
