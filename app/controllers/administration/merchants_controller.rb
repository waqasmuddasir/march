class Administration::MerchantsController < ApplicationController
  before_filter :detect_browser
  before_filter :authorize_admin
  before_filter :find_merchant, :only=>[:show, :edit, :update, :destroy]
  layout "administration/admin"  
  def index
    @administration_merchants = Administration::Merchant.all

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @administration_merchants }
    end
  end
  
  def show    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @administration_merchant }
    end
  end

  def new
    @administration_merchant = Administration::Merchant.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @administration_merchant }
    end
  end

 
  def edit    

  end

  def create
    params[:administration_merchant][:name] = params[:administration_merchant][:name].capitalize.strip
    @administration_merchant = Administration::Merchant.new(params[:administration_merchant])

    respond_to do |format|
      if @administration_merchant.save
        #@administration_merchant.add_merchant_contacts(params[:administration_merchant_contact])
        format.html { redirect_to(@administration_merchant, :notice => 'Merchant was successfully created.') }
        format.xml  { render :xml => @administration_merchant, :status => :created, :location => @administration_merchant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administration_merchant.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update    
   # @administration_merchant.add_merchant_contacts(params[:administration_merchant_contact])
     
    respond_to do |format|
      params[:administration_merchant][:name] = params[:administration_merchant][:name].capitalize.strip
      if @administration_merchant.update_attributes(params[:administration_merchant])
        format.html { redirect_to(@administration_merchant, :notice => 'Merchant was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administration_merchant.errors, :status => :unprocessable_entity }
      end
    end
  end

 
  def destroy
    @administration_merchant.destroy

    respond_to do |format|
      format.html { redirect_to(administration_merchants_url) }
      format.xml  { head :ok }
    end
  end

  def load_contacts
     @contacts = Administration::Contact.all
  end

  private

  def find_merchant
    @administration_merchant = Administration::Merchant.find(params[:id])
  end
  
end
