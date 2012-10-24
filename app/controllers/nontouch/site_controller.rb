class Nontouch::SiteController < ApplicationController
  layout "nontouch/mobile_site"

   LOCAL_SETTINGS = YAML.load_file("#{Rails.root.to_s}/config/local_settings.yml")
  API_URL = LOCAL_SETTINGS["api_url"].to_s
  def authorize_user
    session[:auth_token].blank? ? (redirect_to :controller => "/mobile/sessions", :action => "new" and return false) : (return true)
  end
  def clear_loggedin_user
     session[:auth_token] = nil
     session[:name] = nil
     session[:email] = nil
  end
end
