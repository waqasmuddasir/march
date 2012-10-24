require 'htmlentities'
class Administration::OfferingsController < ApplicationController
  before_filter :authorize_admin
  before_filter :find_offering, :only=>[:show, :edit, :update, :destroy]
  # GET /administration/offerings
  # GET /administration/offerings.xml
  layout "administration/admin"
  def index
    @administration_offerings = Administration::Offering.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administration_offerings }
    end
  end

  # GET /administration/offerings/1
  # GET /administration/offerings/1.xml
  def show
    @administration_offering.description=HTMLEntities.decode_entities(@administration_offering.description)
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administration_offering.nil? ? "<error><code>400</code><status>Not found</status></error>":@administration_offering}
    end
  end

  # GET /administration/offerings/new
  # GET /administration/offerings/new.xml
  def new
    @administration_offering = Administration::Offering.new
    load_merchants
    @merchant_offerings = Administration::MerchantOffering.find(:all)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administration_offering }
    end
  end

  # GET /administration/offerings/1/edit
  def edit    
     load_merchants
    @merchant_offerings = Administration::MerchantOffering.find(:all)
  end

  # POST /administration/offerings
  # POST /administration/offerings.xml
  def create
    html = HTMLEntities.new
    params[:administration_offering][:description] = html.encode(params[:administration_offering][:description])
    @administration_offering = Administration::Offering.new(params[:administration_offering])

    respond_to do |format|
      if @administration_offering.save
        @administration_offering.add_offering_merchants(params[:administration_merchant_offering])
        format.html { redirect_to(@administration_offering, :notice => 'Offering was successfully created.') }
        format.xml  { render :xml => @administration_offering, :status => :created, :location => @administration_offering }
      else
        load_merchants
        @merchant_offerings = Administration::MerchantOffering.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @administration_offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /administration/offerings/1
  # PUT /administration/offerings/1.xml
  def update    
    @administration_offering.delete_offering_merchants
    @administration_offering.add_offering_merchants(params[:administration_merchant_offering])
    respond_to do |format|
      if @administration_offering.update_attributes(params[:administration_offering])
        format.html { redirect_to(@administration_offering, :notice => 'Offering was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administration_offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administration/offerings/1
  # DELETE /administration/offerings/1.xml
  def destroy    
    @administration_offering.destroy

    respond_to do |format|
      format.html { redirect_to(administration_offerings_url) }
      format.xml  { head :ok }
    end
  end

  def load_merchants
    @merchants = Administration::Merchant.find(:all)
  end

  private

  def find_offering
    @administration_offering = Administration::Offering.find(params[:id])
  end
end
