class Api::UsersController < ApplicationController
  def index

  end
  def create
    @message = Api::Message.find_by_code(200)
    @message.detail = "Login successful"
    package = Administration::MerchantPackage.find(:first,:conditions => {:id => params[:user][:package_id]})
    if !package.nil?
       if !params[:user].nil?
        @user = User.new(params[:user])
        @user.name=params[:user][:name]
        @user.email=params[:user][:login]
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
         @message.detail = "You have to provided any signup information"
      end
    else
      @user = User.new
      @message = Api::Message.find_by_code(401)
      @message.detail = "Could not sign up, package does not exist"
      @user.errors.add_to_base("Could not sign up, package does not exist")
    end

     respond_to do |format|
      format.xml  { render "/api/users/signup.xml", :content_type => "text/xml"}
    end
  end
end
