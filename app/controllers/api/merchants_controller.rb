class Api::MerchantsController < Api::AuthController
  before_filter :validate_auth_token
   def index
     if params[:merchant] && params[:merchant][:category_id]
        @merchants = Administration::Merchant.find(:all,:conditions => {:merchant_category_id => params[:merchant][:category_id]},:include => [:merchant_category])
     else
        @merchants = Administration::Merchant.find(:all,:include => [:merchant_category])
     end
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"

    respond_to do |format|      
      format.xml  { render "/api/merchants/index.xml" }
    end
  end
  def show
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"
    @merchant = Administration::Merchant.find(params[:id])
    respond_to do |format|
      format.xml  { render "/api/merchants/show.xml" }
    end
  end
  def create
    @message = Api::Message.find_by_code(403)
    @message.detail = "You do not have rights to create new merchant."

    respond_to do |format|
      format.xml  { render "/api/merchants/index.xml" }
    end
  end
  def destroy
    @message = Api::Message.find_by_code(403)
    @message.detail = "You do not have rights to destroy merchants."
    respond_to do |format|
      format.xml  { render "/api/merchants/index.xml" }
    end
  end
  
end
