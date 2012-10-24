class Api::OfferingsController < Api::AuthController
  before_filter :validate_auth_token
  def index
    user = User.find_by_auth_token(params[:user][:auth_token])      
    if params[:offering]
    else
      @offerings = user.get_offerings
    end
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"

    respond_to do |format|
      format.xml  { render "/api/offerings/index.xml" }
    end
  end
  def show
    @message = Api::Message.find_by_code(200)
    @message.detail = "Authenticated"
    @offering = Administration::Offering.find(params[:id])
    respond_to do |format|
      format.xml  { render "/api/offerings/show.xml" }
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
