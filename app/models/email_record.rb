class EmailRecord < ActiveRecord::Base
  has_many :potential_user_email_records, :dependent => :destroy
  has_many :potential_users, :through => :potential_user_email_records
  belongs_to :merchant_package

   def send_email_with_sign_up_offer recipient_emails, package_id
    if !recipient_emails.nil? && !recipient_emails.blank? && !package_id.nil?
      
      # 1) Add empty rec, to get the email_id for reference..
      email_id=create_empty_record

      # 2) get Package
      package=Administration::MerchantPackage.find(package_id)

      # 3) create reference for email-users & store Potential Users in database
      recipient_emails=create_potential_user_references recipient_emails, email_id, package_id
      return false if recipient_emails.nil? && recipient_emails.blank?

      # 4) Creating Signup link
      link="http://#{ApplicationController::SITE_URL}/signup/#{package.id}"

      # 5) preparing hashes to replace tags in email template
      subject_tags  ={:OFFERING_TITLE => package.offering.title,:PACKAGE_TITLE => package.title}
      body_tags ={:OFFERING_TITLE => package.offering.title,:OFFERING_DESCRIPTION => package.offering.description,:PACKAGE_TITLE => package.title,:PACKAGE_DESCRIPTION => package.description,:LINK => link}

      # 6) replace tags in email template
      body= Administration::EmailTemplate.parse_body(body_tags, 2)
      subject= Administration::EmailTemplate.parse_subject(subject_tags, 2)

      # 7) send email
      UserMailer.send_email(recipient_emails, subject, body).deliver

      # 8) update the email record
      email_record = EmailRecord.find(email_id)
      email_record.recipient=recipient_emails
      email_record.subject=subject
      email_record.body=body
      email_record.merchant_package_id=package.id
      email_record.save
      return true
    else
      return false
    end
  end

private
  
  def create_potential_user_references csv, email_id, package_id
    # Insert User from csv emails & create references with email & package:

    valid_email_csv=""
    if !csv.empty?
      # parsing email from csv file

      csv.each "," do |email|
        email=email.to_s.gsub("'","")
        email=email.to_s.gsub(",","")
        email=email.to_s.gsub('"',"")
        email=email.to_s.gsub(' ',"")
        
        # 1) Insert potential Users (inseting only email address) & get user.id
        user_id =  PotentialUser.create_by_email email
        if user_id !=nil && user_id >0
          
          # 2) add reference (Insert) in PotentialUserPackage
          PotentialUserPackage.create_by_ids package_id, user_id

          # 3) add reference (Insert) in PotentialUserEmailRecord
          PotentialUserEmailRecord.create_by_ids email_id, user_id
          
          # 4) create string of csv email addresses.
          valid_email_csv =valid_email_csv + email + ", "
        else
          # this is additional, when email is being sent to the user already existed in the DB ......
              valid_email_csv =valid_email_csv + email + ", "
        end
      end
      return valid_email_csv.chop.chop
    end
    return nil
  end



   def create_empty_record
      email_record = EmailRecord.new
      email_record.sender=ApplicationController::ADMINEMAIL
      email_record.email_type=1
      email_record.save
      return email_record.id
  end
end

