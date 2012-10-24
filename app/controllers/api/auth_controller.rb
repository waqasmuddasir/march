require "net/http"
class Api::AuthController < ApplicationController  
  include AuthenticatedSystem
  protect_from_forgery :only => [:update, :delete, :create]
  
  def index    
    
  end
  
  def create
    
    if request.post?
      @user = User.authenticate(params[:user][:login], params[:user][:password])
      if @user != nil
        @user.generate_auth_token
        @message = Api::Message.find_by_code(200)
        @message.detail = "Login successfull"
      else
        @message = Api::Message.find_by_code(401)
        user_email = User.find_by_login(params[:user][:login])
        if user_email.nil?
          @message.detail = "Invalid Email Address"
        else
          @message.detail = "Invalid Password"
        end
        
      end
    else
        @message = Api::Message.find_by_code(401)
        @message.detail = "Invalid Email/password"
    end
    
    respond_to do |format|      
      format.xml  { render "/api/auth/response.xml", :content_type => "text/xml"}
    end
  end

  def validate_auth_token
      @user = User.find_by_auth_token(params[:user][:auth_token]) rescue nil
      @user == nil ? (auth_failed) : (return true)    
  end
  def show
    @user = User.find_by_auth_token(params[:id])
      if @user != nil       
        @message = Api::Message.find_by_code(200)
        @message.detail = "Login successfull"
      else
        @message = Api::Message.find_by_code(401)
        @message.detail = "Invalid username/password"
      end   

    respond_to do |format|
      format.xml  { render "/api/auth/response.xml", :content_type => "text/xml"}
    end
  end
  def forgot_password
    if !params[:user].nil?
      @user = User.find_by_email(params[:user][:email])
      if @user != nil
        @message = Api::Message.find_by_code(200)
       
        if params[:user][:send_link_to].to_s == "mobile"
           @message.detail = @user.sms_password_reset_link
        else
          @user.send_password_reset_link
          @message.detail = "Password reset link has been sent to your provided email address."
        end
        
      else
        @message = Api::Message.find_by_code(401)
        @message.detail = "Provided email address is not registered with Ultra."
      end
    else
       @message = Api::Message.find_by_code(401)
       @message.detail = "No email address was sent."
    end
    

    respond_to do |format|
      format.xml  { render "/api/auth/response.xml", :content_type => "text/xml"}
    end
  end
  def reset_password
    if !params[:user].nil?
      @user = User.find_by_password_reset_code(params[:password_reset_code])
      if @user != nil
        
        if  params[:user][:password_confirmation] != params[:user][:password]
          @message = Api::Message.find_by_code(401)
          @message.detail = "Confirm password does not match."
        else
          @message = Api::Message.find_by_code(200)
          @message.detail = "Your password has been changed."
          @user.password_confirmation = params[:user][:password_confirmation]
          @user.password = params[:user][:password]
          @user.reset_password
          @user.save(:validate => false)
        end
        
      else
        @message = Api::Message.find_by_code(401)
        @message.detail = "Reset URL is expired."
      end
    else
       @message = Api::Message.find_by_code(401)
       @message.detail = "Reset URL is expired."
    end


    respond_to do |format|
      format.xml  { render "/api/auth/response.xml", :content_type => "text/xml"}
    end
  end
  def signup
    if !params[:user].nil?
      @user = User.new(params[:user])
      @user.name=params[:user][:name]
      @user.email=params[:user][:login]
      @user.email_notification=params[:user][:email_notification]
      @user.password_confirmation=params[:user][:password]
      success = @user && @user.save

      if success && @user.errors.empty?
        @user.generate_auth_token
        @user.add_package(params[:user][:package_id])
      else
        @message = Api::Message.find_by_code(401)
        @message.detail = "errors found"
      end
    else
       @message = Api::Message.find_by_code(401)
       @message.detail = "You have not provided any signup information"
    end
     respond_to do |format|
      format.xml  { render "/api/auth/signup.xml", :content_type => "text/xml"}
    end
  end
  protected 
  def auth_failed
     @message = Api::Message.find_by_code(401)
     @message.detail = "Invalid auth token"
     respond_to do |format|
      format.xml  { render "/api/auth/response.xml", :content_type => "text/xml"}
    end
    return false
  end
  
  
end
