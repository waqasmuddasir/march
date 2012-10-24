class Nontouch::UsersController < Nontouch::SiteController
 # caches_action :forgot_password
  def forgot_password
    clear_loggedin_user
    return unless request.post?
    if !params[:user][:email].blank?
       
        url = URI.parse("#{Nontouch::SiteController::API_URL}/auth/forgot_password/request.xml")
        request = Net::HTTP::Get.new(url.path)
        request.body = "<?xml version='1.0' encoding='UTF-8'?><user><email>"+params[:user][:email].to_s+"</email><send_link_to>#{params[:send_link_to].to_s}</send_link_to></user>"
        request.content_type = 'text/xml'
        http = Net::HTTP.new(url.host, url.port)
        response = http.request(request)
        xml = response.body        
        response_tag = XmlSimple.xml_in(xml)
        if response_tag['code'].to_s == '200'
          @header = "Forgot password"
          @message = response_tag["detail"]
          render :action => "email_sent"
          return
        else
          flash[:error] = response_tag["detail"]
          return
        end
    else
      flash[:error] = "Please enter email address"
    end
  end
  def reset_password
    clear_loggedin_user
    reset_code = params[:password_reset_code].blank? ? (params[:user][:password_reset_code]):(params[:password_reset_code])
    if request.post?
      if ((params[:user][:password] && params[:user][:password_confirmation]) &&
            !params[:user][:password_confirmation].blank?)
        url = URI.parse("#{Nontouch::SiteController::API_URL}/auth/reset_password/#{reset_code}.xml")
        request = Net::HTTP::Get.new(url.path)
        request.body = "<?xml version='1.0' encoding='UTF-8'?><user><password>"+params[:user][:password].to_s+"</password><password_confirmation>#{params[:user][:password_confirmation].to_s}</password_confirmation></user>"
        request.content_type = 'text/xml'
        http = Net::HTTP.new(url.host, url.port)
        response = http.request(request)
        xml = response.body
        response_tag = XmlSimple.xml_in(xml)
        if response_tag['code'].to_s == '200'
          @header = "Reset password"
          @message = response_tag["detail"]
          render :action => "email_sent"
          return
        else
          flash[:error] = response_tag["detail"]
          return
        end
      elsif params[:user][:password].blank?
        flash[:error] = "Enter your new password"
      else
        flash[:error] = "Confirm password does not match"
      end
    end
  end
  def new
    clear_loggedin_user
    @x = ""
    @user = User.new
    if params[:package_id] == nil
      redirect_to :controller => "sessions", :action => "new"
    else
      @package_id = params[:package_id]
    end
  end
  def create
    clear_loggedin_user
    @user = User.new
     @x = "could not connect to server"
    if request.post?
      @user = User.new(params[:user])
      @user.name=params[:user][:name]
      @package_id = params[:package_id]
      url = URI.parse("#{Nontouch::SiteController::API_URL}/users.xml")
      request = Net::HTTP::Post.new(url.path)
      request.body = "<?xml version='1.0' encoding='UTF-8'?><user><name>#{params[:user][:name]}</name><login>"+params[:user][:login]+"</login><password>"+params[:user][:password]+"</password><package_id>#{params[:package_id]}</package_id></user>"
      request.content_type = 'text/xml'
      http = Net::HTTP.new(url.host, url.port)
      response = http.request(request)
      xml = response.body
      @x = xml
      response_tag = XmlSimple.xml_in(xml)
      if response_tag['code'].to_s == '200'
        session[:auth_token] = response_tag["user"][0]["auth_token"]
        session[:name] = response_tag["user"][0]["name"]
        session[:email] = response_tag["user"][0]["email"]
        redirect_to :controller => "packages", :action => "show",:id => @package_id,:auth_token => session[:auth_token]
        return
      else
        @errors = response_tag['errors'][0]["error"] rescue nil
      end
    end
    render :new
  end
end
