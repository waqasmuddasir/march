class Administration::MerchantCategoriesController < ApplicationController
  before_filter :detect_browser
  before_filter :authorize_admin
  before_filter :find_merchant_category, :only=>[:show, :edit, :update, :destroy]
  layout "administration/admin"
  def index
    @administration_merchant_categories = Administration::MerchantCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administration_merchant_categories }
    end
  end

  def show    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administration_merchant_category }
    end
  end

  def new
    @administration_merchant_category = Administration::MerchantCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administration_merchant_category }
    end
  end
  def edit
  end
  def create
    @administration_merchant_category = Administration::MerchantCategory.new(params[:administration_merchant_category])

    respond_to do |format|
      if @administration_merchant_category.save
        format.html { redirect_to(@administration_merchant_category, :notice => 'Merchant category was successfully created.') }
        format.xml  { render :xml => @administration_merchant_category, :status => :created, :location => @administration_merchant_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administration_merchant_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @administration_merchant_category.update_attributes(params[:administration_merchant_category])
        format.html { redirect_to(@administration_merchant_category, :notice => 'Merchant category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administration_merchant_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @administration_merchant_category.destroy

    respond_to do |format|
      format.html { redirect_to(administration_merchant_categories_url) }
      format.xml  { head :ok }
    end
  end

  private
  def find_merchant_category
    @administration_merchant_category = Administration::MerchantCategory.find(params[:id])
  end
end
