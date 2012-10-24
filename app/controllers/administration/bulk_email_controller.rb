class Administration::BulkEmailController < ApplicationController

  before_filter :authorize_admin
  before_filter :detect_browser
  layout "administration/admin"

  def send_email

      if params[:package_id]!=nil && !params[:package_id].blank? && params[:package_id].to_i > 0

      email_record = EmailRecord.new
        if email_record.send_email_with_sign_up_offer( params[:to].to_s, params[:package_id])
          flash.now[:notice]="email has been sent to the following email addresses.."
          @emails=params[:to].to_s
          render :email_address_list
          return
        else
          flash.now[:notice]="error sending email. Invalid email address.."
        end
      else
          flash.now[:notice]="Please select the package for signup offer.."
      end
      render :index
  end

  def index

  end

  def extract_area_wise_email
    area = Area.find(params[:area_id])
    @csv = area.get_potential_user_emails
    render :index
  end


  def extract_csv
    @csv = DataFile.extract_csv(params[:upload])
    render :index
  end

  def new_email_address
  end

  def upload_n_save_csv
    @csv = DataFile.extract_csv(params[:upload])
    if !@csv.empty?
      potential_user = PotentialUser.new
      count= potential_user.inser_potential_user_email(@csv)
      flash.now[:notice]="(" + count.to_s + ") email addresses saved"
    else
      flash.now[:notice]="Please add email addresses..."
    end
    render :new_email_address
  end
end
