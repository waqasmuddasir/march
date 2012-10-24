# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  before_filter :detect_browser

    
    layout "users"
    
  # render new.rhtml
  def index
     
  end
  def new
    if !flash[:notice].nil?
      flash[:notice] = flash[:notice] #TODO is this really required
    end
    if !current_user.nil?
      return if not_redeem_yet?(current_user.user_packages[0].merchant_package_id)
      redirect_to :controller => :offered_packages, :action => :current
    end
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      #redirect_back_or_default('/', :notice => "Logged in successfully")
      
      flash[:notice]  = " Welcome to Ultra.co.uk."
    
      # redirection to first available deal redemption page... (lately Added)
       if !session["package_id_to_assign"].nil?
          package = Administration::MerchantPackage.find(session["package_id_to_assign"])
         #adding package to user
          current_user.add_package(session["package_id_to_assign"])
          if !session[:signup_url].nil? && !session[:signup_url].blank?
            current_user.save_signup_url(session[:signup_url])
            session[:signup_url] = nil
          end
          session["package_id_to_assign"]=nil
          redirect_to :controller=>:users, :action => :offer_redeem,:package_id => package.id
          return

       elsif not_redeem_yet?( (current_user.user_packages.count>0 and current_user.user_packages[0].merchant_package_id and session["package_id_to_assign"].nil?) )
        return       
      end
      redirect_to :controller => :offered_packages, :action => :current
      return   
    end
     note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash[:error] = "Couldn't log you in as '#{params[:login]}'"
      redirect_to :controller => :sessions, :action => :new    
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default('/', :notice => "You have been logged out.")
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def not_redeem_yet?(condition)
    if condition
      package = Administration::MerchantPackage.find(current_user.user_packages.last.merchant_package_id)
      redirect_to :controller=>:users, :action => :offer_redeem,:package_id => package.id
      return true
    end
    return false
  end
end
