require 'xmlsimple'
class Nontouch::PackagesController < Nontouch::SiteController
  before_filter :authorize_user, :except => [:show]
  #caches_action :index, :show,:redeem,:package_timer,:verify_code
  skip_before_filter :verify_authenticity_token
  CODES= [["1", "m_code_1"],
    ["2", "m_code_2"],
    ["3", "m_code_3"],
    ["4", "m_code_4"],
    ["5", "m_code_5"],
    ["6", "m_code_6"],
    ["7", "m_code_7"],
    ["8", "m_code_8"]
  ]
  def index
    @message = "No packages found";
    url = URI.parse("#{Nontouch::SiteController::API_URL}/packages.xml")
    request = Net::HTTP::Get.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8'?><user><auth_token>"+session[:auth_token].to_s+"</auth_token></user>"
    request.content_type = 'text/xml'
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    xml = response.body
    @tem = xml
    #xml.gsub(/(>)\s*(<)/, '\1\2').gsub(/\n+/, "")
    response_tag = XmlSimple.xml_in(xml)
    if response_tag['code'].to_s == '200'
      @packages = response_tag['packages'][0]['package'] rescue nil

      if !@packages.nil? && @packages.size == 1
        redirect_to :controller => "packages", :action => "show",:id=>@packages[0]['id'].to_s,:auth_token => session[:auth_token].to_s
      end
      @message = "";
    end

  end
 def show
    if !params[:id].nil? && !params[:auth_token].nil?
      @message = "No details found";
      clear_loggedin_user
      url = URI.parse("#{Mobile::SiteController::API_URL}/auth/#{params[:auth_token]}.xml")
      request = Net::HTTP::Get.new(url.path)
      http = Net::HTTP.new(url.host, url.port)
      response = http.request(request)
      xml = response.body
      @temp = xml
      response_tag = XmlSimple.xml_in(xml)
      if response_tag != nil && response_tag["code"].to_s == "200"
        session[:auth_token] = response_tag["user"][0]["auth_token"]
        session[:name] = response_tag["user"][0]["name"]
        session[:email] = response_tag["user"][0]["email"]

        url = URI.parse("#{Mobile::SiteController::API_URL}/packages/#{params[:id]}.xml")
        request = Net::HTTP::Get.new(url.path)
        request.body = "<?xml version='1.0' encoding='UTF-8'?><user><auth_token>"+response_tag["user"][0]["auth_token"].to_s+"</auth_token></user>"
        request.content_type = 'text/xml'
        http = Net::HTTP.new(url.host, url.port)
        response = http.request(request)
        xml = response.body
        @tem = xml

        response_tag = XmlSimple.xml_in(xml)
        if response_tag['code'].to_s == '200'
          @package = response_tag['package'][0] rescue nil
          @offering = response_tag['package'][0]['offering'][0] rescue nil
          @merchants = response_tag["package"][0]["merchants"][0]["merchant"] rescue nil
          @message = "";
        end

      else
        login
      end
    else
      login
    end
  end
  def redeem

    @message = "No details found";
    @error = "no"
    url = URI.parse("#{Mobile::SiteController::API_URL}/packages/redeem/#{params[:id]}.xml")
    request = Net::HTTP::Get.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8'?><user><auth_token>"+session[:auth_token].to_s+"</auth_token></user>"
    request.content_type = 'text/xml'
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    xml = response.body

    response_tag = XmlSimple.xml_in(xml)
    if response_tag['code'].to_s == '200'

      @package = response_tag['package'][0] rescue nil
      @offering = response_tag['package'][0]['offering'][0] rescue nil
      @message = "";
      if @package["is_valid"].to_s == "true"
        @message = "valid"
        @redeem_id = @package["redeem_id"]
        #redirect_to  :action => :package_timer,:id => @package["id"].to_s
       # return
      else
        server_error =   response_tag['detail'].nil? ? "Your package doesn't exist any more":response_tag['detail'].to_s;
      @error = "<b>Unable to redeem package</b> <br/>"+server_error
      end
    else
      server_error =   response_tag['detail'].nil? ? "Your package doesn't exist any more":response_tag['detail'].to_s;
      @error = "<b>Unable to redeem package</b> <br/>"+server_error
     # render :package_expired
     # return
    end

    respond_to do |format|
      format.js {render(:partial => 'redeem_response', :layout => false)}
    end
    #redirect_to :action => :package_expired
  end
  def package_timer
    url = URI.parse("#{Mobile::SiteController::API_URL}/packages/redeem/#{params[:id]}.xml")
    request = Net::HTTP::Get.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8'?><user><auth_token>"+session[:auth_token].to_s+"</auth_token></user>"
    request.content_type = 'text/xml'
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    xml = response.body

    response_tag = XmlSimple.xml_in(xml)

    if response_tag['code'].to_s == '200'

      @package = response_tag['package'][0] rescue nil
      @offering = response_tag['package'][0]['offering'][0] rescue nil
      @message = "valid";
      if @package["is_valid"].to_s == "false"
        @message = "valid";
        #redirect_to :action => :package_expired
        #return
      end
      @redeem_id = @package["redeem_id"]

    end

  end
  def package_expired
    @error = "Unable to redeem package. This could be because:
              <ul>
                <li>The offer is currently unavailable.</li>
                <li>You have already redeemed the offer.</li>
                <li>The merchant did not successfully verify the offer.</li>
              </ul>"
  end
  def timer_expired
    @error = "'Verification failed - time expired"
    render :package_expired
  end
  def login
    redirect_to :controller => :sessions, :action => "new"
    return
  end
  def verify_code
    @status = ""
    @error = ""
    @merchant_message = ""
    url = URI.parse("#{Mobile::SiteController::API_URL}/packages/verify/#{params[:id]}.xml")
    request = Net::HTTP::Get.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8'?>
            <user>
                <auth_token>"+session[:auth_token].to_s+"</auth_token>
                <package_verification_code>#{params[:verification_code]}</package_verification_code>
                <redeem_id>#{params[:redeem_id]}</redeem_id>
            </user>"
    request.content_type = 'text/xml'
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    xml = response.body

    response_tag = XmlSimple.xml_in(xml)
    @x = response_tag['code'].to_s
    if response_tag['code'].to_s == '200'

      @status = "VERIFICATION SUCCESSFUL"
      @error = "";
      @package = response_tag['package'][0] rescue nil
      @offering = response_tag['package'][0]['offering'][0] rescue nil
      @merchant_message = "Please give #{session[:name].to_s} #{@package["title"].to_s}"
      #render :verification_response
      #return

    elsif response_tag['code'].to_s == '401'
#      @error = "Unable to redeem package. This could be because:
#              <ul>
#                <li>The offer is currently unavailable.</li>
#                <li>You have already redeemed the offer.</li>
#                <li>The merchant did not successfully verify the offer.</li>
#              </ul>"
      @package = response_tag['package'][0] rescue nil
      @offering = response_tag['package'][0]['offering'][0] rescue nil
      @status = "VERIFICATION FAILED"
      @error = response_tag['detail'].nil? ? "Your package doesn't exist any more":response_tag['detail'].to_s;
      @merchant_message = "You may still honour #{session[:name].to_s}'s discount at your discrection"
      #render :verification_response
      #return
    elsif response_tag['code'].to_s == '400'
      @status = "VERIFICATION FAILED"
      server_error =   response_tag['detail'].nil? ? "Your package doesn't exist any more":response_tag['detail'].to_s;
      @error = "<b>Unable to redeem package</b> <br/>"+server_error
      @merchant_message = "You may still honour #{session[:name].to_s}'s discount at your discrection"
      #render :package_expired
      #return
    else
      @status = "VERIFICATION FAILED"
      server_error = response_tag['detail'].nil? ? "Your package doesn't exist any more":response_tag['detail'].to_s;
      @error = "<b>Unable to redeem package</b> <br/>"+server_error
      @merchant_message = ""
      #render :verification_response
      #return
    end
    #render :package_expired
    respond_to do |format|
        format.js {render(:partial => 'verify_ajax_response', :layout => false)}
    end
  end
  def invalid_code

  end
  def redeemed

  end
  
end
