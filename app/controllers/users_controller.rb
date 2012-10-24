require 'htmlentities'
class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  before_filter :login_required, :except=>[:create,:new, :offer_redeem, :offer_redeemed_by_email,:forgot_password,:reset_password,:foodsecret,:valmont]
  before_filter :detect_browser
  include AuthenticatedSystem
  include Utils
  #####################
  
  
  layout 'users'
  include AuthenticatedSystem

  # render new.rhtml
  def new
    logout_keeping_session!
    @signup=true
    @user = User.new
    @package = nil    
    if params[:package_id] != nil
       session["package_id_to_assign"] = params[:package_id]
      @html = HTMLEntities.new
      @package = Administration::MerchantPackage.find(:first,:conditions => {:id=>params[:package_id]})
      @offering=   Administration::Offering.find(:first,:conditions => {:id=>@package.offering_id})
      @packages = Administration::MerchantPackage.all(:conditions => {:offering_id=>@package.offering_id})
    end
  end

  def logout
    logout_killing_session!
    flash[:error]  = "You have been Logged out of the system.."
    redirect_to "/home"
  end

  def create
    logout_keeping_session!
   
    @user = User.new(params[:user])
    @user.name=params[:user][:name]
    @user.email=params[:user][:login]
    @user.email_notification=params[:user][:email_notification]
    @user.password_confirmation=params[:user][:password]
    
    if @user.email_and_package_subscribed? params[:package_id]
      flash[:error] = "You are already registered. Please log in to redeem the deal."
      session["package_id_to_assign"]=params[:package_id]
      redirect_to :action=> :new, :package_id => params[:package_id]

      return
    end

    success = @user && @user.save
    
    if success && @user.errors.empty?
      #--------------------------------------
      # This copies the all offered packages prior to user registration
      # @user.copy_offered_packages
      #--------------------------------------

      self.current_user = @user # !! now logged in
      @user.generate_auth_token # generate authentication for mobile app
      if params[:package_id] != nil
        
        # @user.create_first_group #first user group associated to this user
        
        @user.add_package(params[:package_id])
        @package_id = params[:package_id]       
        if !session[:signup_url].nil? && !session[:signup_url].blank?
          @user.save_signup_url(session[:signup_url])
          session[:signup_url] = nil
        end
        
        flash[:notice] = "Thanks for confirming your details - we've e-mailed redemption instructions to #{current_user.email}"
        redirect_to :action => :offer_redeem,:package_id => params[:package_id]
      else
        @user.create_event_log
        flash[:notice] = "Thanks for confirming your details - We will soon update on our exciting offers. "
        redirect_to :action => :index
      end
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."      
      @package = nil
      if params[:package_id] != nil
        @html = HTMLEntities.new
        @package = Administration::MerchantPackage.find(:first,:conditions => {:id=>params[:package_id]})
        @offering=   Administration::Offering.find(:first,:conditions => {:id=>@package.offering_id})
        @packages = Administration::MerchantPackage.all(:conditions => {:offering_id=>@package.offering_id})
      end
      render :action=> :new, :package_id => params[:package_id]
    end
  end
    
  def edit
    @user = User.find(params[:id])    
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    @user.name=params[:user][:name]
    @user.email_notification=params[:user][:email_notification]
    @user.sms_notification=params[:user][:sms_notification]
    @user.mobile = strip_mobile!(params[:user][:mobile])

    success = @user && @user.save
    
    if success && @user.errors.empty?
      flash[:notice]="Your account settings have been saved."
      redirect_to :controller => "sessions",:action => "new"
    else
      flash[:error]="Your account settings could not be saved."
      render :edit
    end
    
    
    
  end


  def update_password
    if User.authenticate(current_user.login, params[:users][:old_password])
      if ((params[:users][:password] == params[:users][:password_confirmation]) &&
            !params[:users][:password_confirmation].blank?)

        current_user.password_confirmation = params[:users][:password_confirmation]
        current_user.password = params[:users][:password]
        current_user.password_changed?

        
        
        if current_user.errors.count==0
          if current_user.save(false)
            flash[:notice] = "Password successfully updated"
          else
            flash[:error] = "Password not changed, invalid password "
          end
          redirect_to :controller => :users, :action => :show, :id=>current_user.id
        else

          err=""
          current_user.errors.full_messages.each do |msg|
            err+=" - " + msg
          end

          flash[:error] = "Password not changed. "+ err
          @user  =current_user
          redirect_to :action=>:change_password, :id=>current_user.id
        end
      else
        flash[:error] = "Password not changed. New Password mismatch"
        @old_password = params[:old_password]
        @user  =current_user
        redirect_to :action=>:change_password, :id=>current_user.id
      end
    else
      flash[:error] = "Password not changed. Old password incorrect"
      @user  =current_user
      redirect_to :action=>:change_password, :id=>current_user.id
    end

  end

  
  def change_password
    @user=current_user
  end
  

  def offer_redeem
    if !params[:package_id].nil?
      @package_id = params[:package_id]
      @package = Administration::MerchantPackage.find(params[:package_id])

      if @package.access_code.nil? or @package.access_code.blank?
        @package.access_code=@package.get_access_code
      end

      @user_package = UserPackage.find(:first,:conditions => {:merchant_package_id => params[:package_id],:user_id => current_user.id})
      @group_member=GroupMember.new
    else
      flash[:notice]  = " Welcome to Ultra.co.uk. Thanks for signing up. An Email has been sent to your account.."
      redirect_to :controller => :sessions, :action => :new
    end
  end

  

  def offer_redeemed_by_email
    package=Administration::MerchantPackage.find(params[:id].to_i)
    package.send_redemption_link(current_user)

    flash[:notice]  = "Redemption link has been sent to #{current_user.email}"
    #redirect_to :controller => :sessions, :action => :new
    #redirect_to :controller => :offered_packages, :action => :current
    redirect_to :action => :offer_redeem,:package_id => package.id
  end

  def sign_up_notification_email
    package=Administration::MerchantPackage.find(params[:id].to_i)
    package.send_redemption_link(current_user)

    flash[:notice]  = " An Email has been sent to your account.."
    redirect_to :offer_redeem, :package_id => params[:package_id]
  end
  def forgot_password
    logout_keeping_session!
    return unless request.post?
    if @user = User.find_by_email(params[:users][:email])
      @user.send_password_reset_link      
      flash[:notice] = "A password reset link has been sent to your email address"
      redirect_to :controller => "sessions", :action=>"new"
    else
      flash[:error] = "Please provide valid email address.."
    end
  end

  #reset password
  def reset_password
    reset_code = params[:password_reset_code].blank? ? (params[:user][:password_reset_code]):(params[:password_reset_code])
    @user = User.find_by_password_reset_code(reset_code)

    return if @user unless params[:user]
    if request.post?
      if ((params[:user][:password] && params[:user][:password_confirmation]) &&
            !params[:user][:password_confirmation].blank?)

        #self.current_user = @user
        @user.password_confirmation = params[:user][:password_confirmation]
        @user.password = params[:user][:password]
        @user.reset_password
        flash[:notice] = @user.save(:validate => false) ? "Password reset success." : "Password reset failed."
        #redirect_back_or_default('/')
        redirect_to :controller => "sessions", :action=>"new"
      else
        flash[:error] = "Password mismatch"
      end
    end
  end
  def  send_link_on_mobile
    flash[:notice] = ""
    if !current_user.nil? && !params[:user][:mobile].blank?        
        current_user.mobile = strip_mobile!(params[:user][:mobile])
        #current_user.save(:validate => false)
        if current_user.valid?
        current_user.save
        flash[:notice] = current_user.send_package_link_text(params[:id])
      else
        flash[:error] = "Mobile number already exist."
      end
    else
      flash[:error] = "You've not provided your number."
    end
    redirect_to :controller => "users", :action => "offer_redeem",:package_id => params[:id]
    
  end
  def foodsecret
    logout_keeping_session!
    @user = User.new
    @package = nil
    package_id = 1
    if package_id != nil
      @html = HTMLEntities.new
      @package = Administration::MerchantPackage.find(:first,:conditions => {:id=>package_id})
      @offering=   Administration::Offering.find(:first,:conditions => {:id=>@package.offering_id})
      @packages = Administration::MerchantPackage.all(:conditions => {:offering_id=>@package.offering_id})
    end
    render :new
  end
  def valmont
    logout_keeping_session!
    @user = User.new    
    package_id = 16
    if package_id != nil
      @html = HTMLEntities.new
      @package = Administration::MerchantPackage.find(:first,:conditions => {:id=>package_id})
      @offering=   Administration::Offering.find(:first,:conditions => {:id=>@package.offering_id})
      @packages = Administration::MerchantPackage.all(:conditions => {:offering_id=>@package.offering_id})
    end
    render :new
  end

  
  def send_invitation   
    if !current_user.mobile.nil? and !current_user.mobile.blank?
      @group_member = GroupMember.new(params[:member])
      if @group_member.valid?
        @group_member.mobile = strip_mobile!(@group_member.mobile)
        
        if @group_member.invite_user(current_user)
          flash[:notice] = "Your invitation has been sent"
        else
          if !@group_member.error.blank?
            flash[:error] = @group_member.error
          else
            flash[:error] = "Sorry we could not send invitation to #{params[:member][:name]} ."
          end
          
        end
        redirect_to :controller => "users", :action => "offer_redeem",:package_id => params[:member][:package_id]
      else
        @package_id = params[:member][:package_id]
        @package = Administration::MerchantPackage.find(params[:member][:package_id])
        @user_package = UserPackage.find(:first,:conditions => {:merchant_package_id => params[:member][:package_id],:user_id => current_user.id})

        render :controller => "users", :action => "offer_redeem",:package_id => params[:member][:package_id]
      end
    else
      flash[:error] = "Please provide your Mobile number before sending invitations.."
      redirect_to :controller => "users", :action => "offer_redeem",:package_id => params[:member][:package_id]
    end
  end
end
