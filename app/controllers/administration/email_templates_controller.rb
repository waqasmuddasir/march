class Administration::EmailTemplatesController < ApplicationController
before_filter :authorize_admin
before_filter :find_email_template, :only=>[:show, :edit, :update, :destroy]
  layout "administration/admin"
  # GET /administration/email_templates
  # GET /administration/email_templates.xml
  def index
    #@administration_email_templates = Administration::EmailTemplate.all
    @administration_email_templates = Administration::EmailTemplate.list

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administration_email_templates }
    end
  end

  # GET /administration/email_templates/1
  # GET /administration/email_templates/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administration_email_template }
    end
  end

  # GET /administration/email_templates/new
  # GET /administration/email_templates/new.xml
  def new
    @administration_email_template = Administration::EmailTemplate.new
    @template_types= Administration::EmailTemplateType.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administration_email_template }
    end
  end

  # GET /administration/email_templates/1/edit
  def edit
    @template_types= Administration::EmailTemplateType.all
  end

  # POST /administration/email_templates
  # POST /administration/email_templates.xml
  def create
    @administration_email_template = Administration::EmailTemplate.new(params[:administration_email_template])

    respond_to do |format|
      if @administration_email_template.save
        format.html { redirect_to(@administration_email_template, :notice => 'Email template was successfully created.') }
        format.xml  { render :xml => @administration_email_template, :status => :created, :location => @administration_email_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administration_email_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /administration/email_templates/1
  # PUT /administration/email_templates/1.xml
  def update
    respond_to do |format|
      if @administration_email_template.update_attributes(params[:administration_email_template])
        format.html { redirect_to(@administration_email_template, :notice => 'Email template was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administration_email_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administration/email_templates/1
  # DELETE /administration/email_templates/1.xml
  def destroy
    @administration_email_template.destroy

    respond_to do |format|
      format.html { redirect_to(administration_email_templates_url) }
      format.xml  { head :ok }
    end
  end

  private
  def find_email_template
    @administration_email_template = Administration::EmailTemplate.find(params[:id])
  end
end
