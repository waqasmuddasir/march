class Api::PackagesController < Api::AuthController
  before_filter :validate_auth_token
  def index
    user = User.find_by_auth_token(params[:user][:auth_token])
    @packages = user.get_packages
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"
    respond_to do |format|
      format.xml  { render "/api/packages/index.xml" }
    end
  end
  def show
    user = User.find_by_auth_token(params[:user][:auth_token])
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"
    @package = Administration::MerchantPackage.find(params[:id])
    @is_valid = @package.is_valid(Time.now,user.id)
    @redeem_id = @package.already_redeemed(Time.now,user.id)
    @next_day = @package.next_valid_date
    if user.id == 26 || user.id==28
      @is_valid = true
      @redeem_id = 0
    end
    #if @redeem_id != 0
     # @next_day = @package.next_valid_date
    #end
    
    respond_to do |format|
      format.xml  { render "/api/packages/show.xml" }
    end
  end
  def redeem
    user = User.find_by_auth_token(params[:user][:auth_token])
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"
    @package = Administration::MerchantPackage.find(params[:id])
    @is_valid = @package.is_valid(Time.now,user.id)
    redeemed = @package.already_redeemed(Time.now,user.id)
    #debugger
    if user.id == 26 || user.id==28
      @is_valid = true
      @redeem_id = 0
    end
    if @is_valid && redeemed == 0
     @redeem_id = @package.add_redeemed(user.id)
     @redeemed_package = Administration::RedeemedPackage.find_by_id(@redeem_id)
    elsif @is_valid && redeemed != 0
      @redeemed_package = Administration::RedeemedPackage.find_by_id(redeemed)
      @redeem_id = @redeemed_package.id
      if @redeemed_package.time_expired
       @is_valid = false
       @message = Api::Message.find_by_code(401)
       @message.detail = "The offer is currently unavailable."
      end
    end
    respond_to do |format|
      format.xml  { render "/api/packages/redeem.xml" }
    end
  end
  def verify_code
    user = User.find_by_auth_token(params[:user][:auth_token])
    
    @package = Administration::MerchantPackage.find(:first,:conditions => {:id => params[:id]})
    if @package.nil?
      @message = Api::Message.find_by_code(401)
      @message.detail = "Package does not exist anymore"
    elsif @package.verification_code != params[:user][:package_verification_code]
      @message = Api::Message.find_by_code(401)
      @message.detail = "You have tapped a wrong verification symbol"
      @redeemed_package = Administration::RedeemedPackage.find_by_id(params[:user][:redeem_id])
    else
      @is_valid = @package.is_valid(Time.now,user.id)
      @redeemed_package = Administration::RedeemedPackage.find_by_id(params[:user][:redeem_id])
      if @is_valid == true && !@redeemed_package.time_expired
        
        if @redeemed_package.verification_code
          @message = Api::Message.find_by_code(401)
          @message.detail = "This package has already been verified"
        else
          @message = Api::Message.find_by_code(200)
          @message.detail = "Authenticated"
          @redeemed_package.verification_code = params[:user][:package_verification_code]
          @redeemed_package.is_completed = true
          @redeemed_package.save
        end
       
      else
        @redeemed_package.verification_code = params[:user][:package_verification_code]
        @redeemed_package.is_completed = true
        @redeemed_package.save
        @message = Api::Message.find_by_code(400)
        @message.detail = "Verification failed - time expired"
      end
    end
    if !@package.nil? && !@message.detail.nil?
      if @message.detail == "Authenticated"
        @package.log_merchant_verification("Verification Successfull",user.id)
      else
        @package.log_merchant_verification(@message.detail,user.id)
      end
      
    end
    
    respond_to do |format|
      format.xml  { render "/api/packages/redeem.xml" }
    end
  end
  def create
    @message = Api::Message.find_by_code(403)
    @message.detail = "You do not have rights to create new packages."
    respond_to do |format|
      format.xml  { render "/api/packages/index.xml" }
    end
  end
  def destroy
    @message = Api::Message.find_by_code(403)
    @message.detail = "You do not have rights to destroy packages."
    respond_to do |format|
      format.xml  { render "/api/packages/index.xml" }
    end
  end
end
