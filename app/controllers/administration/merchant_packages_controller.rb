class Administration::MerchantPackagesController < ApplicationController
  before_filter :detect_browser
  before_filter :authorize_admin, :except => :remove_redeemed
  before_filter :find_merchant_package, :only=>[:show, :edit, :update, :destroy]
  layout "administration/admin"
  # GET /administration/merchant_packages
  # GET /administration/merchant_packages.xml
  def index
    @administration_merchant_packages = Administration::MerchantPackage.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administration_merchant_packages }
    end
  end

  # GET /administration/merchant_packages/1
  # GET /administration/merchant_packages/1.xml
  def show
    @url = ApplicationController::SITE_URL
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administration_merchant_package }
    end
  end

  # GET /administration/merchant_packages/new
  # GET /administration/merchant_packages/new.xml
  def new
    @administration_merchant_package = Administration::MerchantPackage.new
    @package_rule = Administration::PackageRule.new
    @days = []
    @rule_type = "none"
    @package_allowed_time = Administration::PackageAllowedTime.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administration_merchant_package }
    end
  end

  # GET /administration/merchant_packages/1/edit
  def edit    
    @rule_type = @administration_merchant_package.package_rule.rule_type
    @days = @administration_merchant_package.package_rule.days rescue nil
  end

  # POST /administration/merchant_packages
  # POST /administration/merchant_packages.xml
  def create
     @administration_merchant_package = Administration::MerchantPackage.new(params[:administration_merchant_package])
     @administration_merchant_package.generate_package_rule(params[:days],params[:rule_type],@administration_merchant_package.start_date)     
     @days = params[:days] rescue nil
     @rule_type = "none"
     image = Administration::MerchantPackageImage.new(:uploaded_data => params[:uploaded_data],:merchant_package_id =>@administration_merchant_package.id )
      if !image.valid?
        @administration_merchant_package.errors.add_to_base("Please select valid image")
      end
    respond_to do |format|
      if @administration_merchant_package.errors.blank? && @administration_merchant_package.save
        image = Administration::MerchantPackageImage.new(:uploaded_data => params[:uploaded_data],:merchant_package_id =>@administration_merchant_package.id )
         image.save
        format.html { redirect_to(@administration_merchant_package, :notice => 'Merchant package was successfully created.') }
        format.xml  { render :xml => @administration_merchant_package, :status => :created, :location => @administration_merchant_package }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administration_merchant_package.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /administration/merchant_packages/1
  # PUT /administration/merchant_packages/1.xml
  def update      
    @temp_package = Administration::MerchantPackage.new(params[:administration_merchant_package])
    @administration_merchant_package.generate_package_rule(params[:days],params[:administration_merchant_package][:package_rule_attributes][:rule_type],@temp_package.start_date)
    if !params[:uploaded_data].blank?
      image = Administration::MerchantPackageImage.new(:uploaded_data => params[:uploaded_data],:merchant_package_id =>@administration_merchant_package.id )
      if !image.valid?
          @administration_merchant_package.errors.add_to_base("Please select valid image")
      end
    end
    respond_to do |format|
      if @administration_merchant_package.errors.blank? && @administration_merchant_package.update_attributes(params[:administration_merchant_package])
        if !params[:uploaded_data].blank?
          @administration_merchant_package.delete_images          
          image.save()
        end
        format.html { redirect_to(@administration_merchant_package, :notice => 'Merchant package was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administration_merchant_package.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administration/merchant_packages/1
  # DELETE /administration/merchant_packages/1.xml
  def destroy
    @administration_merchant_package.destroy

    respond_to do |format|
      format.html { redirect_to(administration_merchant_packages_url) }
      format.xml  { head :ok }
    end
  end
  def remove_redeemed
   
      user = User.find_by_id(26)
      if !user.nil?
        user.destroy_redeemed_packages
      end
      user = User.find_by_id(8)
      if !user.nil?
        user.destroy_redeemed_packages
      end
   
  end

  private

  def find_merchant_package
    @administration_merchant_package = Administration::MerchantPackage.find(params[:id])
  end
end
