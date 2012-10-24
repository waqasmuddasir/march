class EmailRecordsController < ApplicationController
  before_filter :login_required
  before_filter :find_email_record, :only=>[:show, :edit, :update, :destroy]
  # GET /email_records
  # GET /email_records.xml
  def index
    @email_records = EmailRecord.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @email_records }
    end
  end

  # GET /email_records/1
  # GET /email_records/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_record }
    end
  end

  # GET /email_records/new
  # GET /email_records/new.xml
  def new
    @email_record = EmailRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_record }
    end
  end

  # GET /email_records/1/edit
  def edit

  end

  # POST /email_records
  # POST /email_records.xml
  def create
    @email_record = EmailRecord.new(params[:email_record])

    respond_to do |format|
      if @email_record.save
        format.html { redirect_to(@email_record, :notice => 'Email record was successfully created.') }
        format.xml  { render :xml => @email_record, :status => :created, :location => @email_record }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /email_records/1
  # PUT /email_records/1.xml
  def update
    respond_to do |format|
      if @email_record.update_attributes(params[:email_record])
        format.html { redirect_to(@email_record, :notice => 'Email record was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /email_records/1
  # DELETE /email_records/1.xml
  def destroy    
    @email_record.destroy

    respond_to do |format|
      format.html { redirect_to(email_records_url) }
      format.xml  { head :ok }
    end
  end

  private

  def find_email_record
    @email_record = EmailRecord.find(params[:id])
  end
end
