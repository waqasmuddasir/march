class SiteRedirectorController < ApplicationController
  TOUCH = 0
  NON_TOUCH = 1
  DESKTOP = 2


  def auto_auth
    browser = get_browser_type
   
    if !params[:stored_url_id].nil?
      stored_url= Administration::StoredUrl.find_by_random_code(params[:stored_url_id])

      if !stored_url.nil?
        case browser
        when TOUCH
          redirect_to :controller => "mobile/packages", :action=>"show",:id=>stored_url.merchant_package_id, :auth_token => stored_url.user_auth_token
          return
        when NON_TOUCH
          redirect_to :controller => "nontouch/packages", :action=>"show",:id=>stored_url.merchant_package_id, :auth_token => stored_url.user_auth_token
          return
        else
          redirect_to :controller => :sessions, :action => "new"
          return
        end
      else

        stored_url= Administration::StoredSignupUrl.find_by_random_code(params[:stored_url_id])

        if !stored_url.nil?
          session[:signup_url] = stored_url.id
          case browser
          when TOUCH
            redirect_to :controller => "mobile/users", :action=>"new",:package_id=>stored_url.merchant_package_id
            return
          when NON_TOUCH
            redirect_to :controller => "nontouch/users", :action=>"new",:package_id=>stored_url.merchant_package_id
            return
          else
            redirect_to :controller => :users, :action => "new",:package_id => stored_url.merchant_package_id
            return
          end
        end

        redirect_to_login
        return
      end
    else
      redirect_to_login
      return
    end
  end

  def redirect_to_login
    browser = get_browser_type
    case browser
    when TOUCH
      redirect_to :controller => "mobile/sessions", :action => "new"
      return
    when NON_TOUCH
      redirect_to :controller => "nontouch/sessions", :action => "new"
      return
    else
      redirect_to :controller => :sessions, :action => "new"
      return
    end
  end



  def reset_password
    browser = get_browser_type
    case browser
    when TOUCH
      redirect_to :controller => "mobile/users", :action => "reset_password", :password_reset_code => params[:password_reset_code]
      return
    when NON_TOUCH
      redirect_to :controller => "nontouch/users", :action => "reset_password", :password_reset_code => params[:password_reset_code]
      return
    else
      redirect_to :controller => "users", :action => "reset_password", :password_reset_code => params[:password_reset_code]
      return
    end
  end

  private

  TOUCH_BROWSERS = ["iphone","android", "ipod"]
  NONTOUCH_BROWSERS = ["opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def get_browser_type
    agent = request.headers["HTTP_USER_AGENT"].downcase

    TOUCH_BROWSERS.each do |m|
      if agent.match(m)
        return TOUCH
      end
    end
    NONTOUCH_BROWSERS.each do |m|
      if agent.match(m)
        return NON_TOUCH
      end
    end
    return DESKTOP
  end

end
