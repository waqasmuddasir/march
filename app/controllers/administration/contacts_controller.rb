class Administration::ContactsController < ApplicationController
  before_filter :authorize_admin
  before_filter :find_contact, :only=>[:show, :edit, :update, :destroy]
  layout "administration/admin"
  def index
    @administration_contacts = Administration::Contact.all

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @administration_contacts }
    end
  end

  
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administration_contact }
    end
  end

  
  def new
    @administration_contact = Administration::Contact.new
    load_merchants
    load_merchant_contacts
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administration_contact }
    end
  end

  
  def edit
    load_merchants
    load_merchant_contacts
  end

  
  def create
    @administration_contact = Administration::Contact.new(params[:administration_contact])

    respond_to do |format|
      if @administration_contact.save        
        @administration_contact.add_contact_merchants(params[:administration_merchant_contact])
        format.html { redirect_to(@administration_contact, :notice => 'Contact was successfully created.') }
        format.xml  { render :xml => @administration_contact, :status => :created, :location => @administration_contact }
      else
        load_merchants
        load_merchant_contacts
        format.html { render :action => "new" }
        format.xml  { render :xml => @administration_contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def update
    respond_to do |format|
      if @administration_contact.update_attributes(params[:administration_contact])
        format.html { redirect_to(@administration_contact, :notice => 'Contact was successfully updated.') }
        format.xml  { head :ok }
      else
        load_merchants
        load_merchant_contacts
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administration_contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def destroy
    @administration_contact.destroy

    respond_to do |format|
      format.html { redirect_to(administration_contacts_url) }
      format.xml  { head :ok }
    end
  end
  def load_merchants
    @merchants = Administration::Merchant.find(:all)
  end
  def load_merchant_contacts
    @merchant_contact = Administration::MerchantContact.find(:all)
  end

  private

  def find_contact
    @administration_contact = Administration::Contact.find(params[:id])
  end
end
