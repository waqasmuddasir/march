require 'ipaddr'
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :find_or_store_ip
  protect_from_forgery

  include AuthenticatedSystem

   LOCAL_SETTINGS = YAML.load_file("#{Rails.root.to_s}/config/local_settings.yml")
   SITE_URL = LOCAL_SETTINGS["site"]
   ADMINEMAIL = LOCAL_SETTINGS["admin_email"]
   API_URL = LOCAL_SETTINGS["api_url"]
   FACEBOOK_URL = LOCAL_SETTINGS["facebook_url"]
   
  def authorize_admin
   session[:admin_id].blank? ? (redirect_to :controller => "admin", :action => "login" and return false) : (return true)
  end
  
  private
  TOUCH_BROWSERS = ["iphone","android", "ipod"]
  NONTOUCH_BROWSERS = ["opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
    agent = request.headers["HTTP_USER_AGENT"].downcase
    TOUCH_BROWSERS.each do |m|
      if agent.match(m)
        redirect_to :controller => "/mobile/sessions", :action => "new" and return false
      end
    end
    NONTOUCH_BROWSERS.each do |m|
      if agent.match(m)
        redirect_to :controller => "/nontouch/sessions", :action => "new" and return false
      end
    end
      return true
  end

  def find_or_store_ip
    client_ip = request.remote_ip    
    integer_ip = IPAddr.new("#{client_ip}").to_i   
    ipcontents = AboutUsMessage.all    
    random    = rand(AboutUsMessage.all.count-1)
    ipcontent = ipcontents[random]
    @ip = Ip.find_or_initialize_by_ipnumber(integer_ip)
    if @ip.new_record?
      @ip.ip = "#{client_ip}"
      @ip.ipcontent_id = ipcontent.id
      @ip.save!
    end

  end
  
end
