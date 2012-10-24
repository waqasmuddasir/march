class Administration::MerchantPackage < ActiveRecord::Base
  
  validates_presence_of :title
  validates_presence_of :description
  validate :validate_dates
  validate :validate_offering
  validate :validate_redemption_instruction

  belongs_to :offering
  has_many :user_packages, :class_name => "::UserPackage", :dependent => :destroy
  has_many :packages, :through => :user_packages
  has_one :package_rule
  accepts_nested_attributes_for :package_rule ,:allow_destroy => true
  has_many :redeemed_packages
  
  has_many :potential_user_packages
  has_many :potential_users, :through => :potential_user_packages

  has_many :email_records
  has_many :email_records, :through => :potential_user_email_records
  has_many :event_logs
  has_one :merchant_package_image, :dependent => :destroy
  has_many :group_members, :class_name => "::GroupMember"


  CODES= [["1", "code_1"],
    ["2", "code_2"],
    ["3", "code_3"],
    ["4", "code_4"],
    ["5", "code_5"],
    ["6", "code_6"],
    ["7", "code_7"],
    ["8", "code_8"]
  ]
  
  def validate_dates
    if self.start_date && self.end_date
      if self.start_date.to_time >= self.end_date.to_time
        errors.add_to_base("Invalid end date.")
      end      
    end
  end
  def validate_offering
    if self.offering_id.nil? or self.offering_id<=0
        errors.add_to_base("Please select Offering.")
    end
  end

  def validate_redemption_instruction
    if self.redemption_instructions.nil? or self.redemption_instructions.blank?
        errors.add_to_base("Please Enter Redemtion instructions.")
    end
  end
  # GENERATE PACKAGE RULE BASED ON SELECTION
  def generate_package_rule(days,rule_type,start_date)

    st_date = start_date # Date.new(start_date["1i"].to_i,start_date["2i"].to_i,start_date["3i"].to_i)
    selected_days = ""
    rule_json = "none"
    is_none = false;
    is_weekly = false;
    is_monthly = false;
    is_yearly = false;
    # CREATE RULE FOR WEEK
    if rule_type == "weekly"
      selected_days = ""
      sep = ""
      if days.nil?
        errors.add_to_base("Please select atleast one day for your selected rule '"+rule_type+"'")
        return false
      else
        days.each do |d|
          selected_days +=sep+""+d.to_s
          sep = ","
        end
      end
      is_weekly = true
    elsif rule_type == "yearly"
      is_yearly = true
    elsif rule_type == "monthly"
      is_monthly = true
    else
      is_none = true
    end

    if(!is_none)
      rule = [{"rule"=>[{
              "weekly"=>[{"valid"=>is_weekly,"days"=>selected_days}],
              "monthly" =>[{"valid"=>is_monthly,"day"=>st_date.mday}],
              "yearly"=>[{"valid"=>is_yearly,"day" =>st_date.mday,"month"=> st_date.month}]
                          
            }]
        }]
      rule_json = JSON.generate rule
    end
    self.package_rule.rule = rule_json

  end
  def is_valid(redeem_time,user_id)
    valid = false
    if self.start_date <= redeem_time  && self.end_date >= redeem_time
      if self.package_rule.is_valid(redeem_time)
        valid = true       
      end
      valid
    end
  end
  # Check if a user has already redeemed a package
  def already_redeemed(redeem_time,user_id)
    redeemed_id = 0
    redeem_packages = Administration::RedeemedPackage.find(:all, :conditions => {:merchant_package_id => self.id,:user_id => user_id})
    if !redeem_packages.nil?
      redeem_packages.each do |redeemed|
        if redeem_time.to_date == redeemed.start_time.to_date
          redeemed_id = redeemed.id
          break
        end
      end
    end
    redeemed_id
  end
  def add_redeemed(user_id)
    redeem = Administration::RedeemedPackage.new
    redeem.user_id = user_id
    redeem.start_time = Time.now
    self.redeemed_packages << redeem
    redeem.id
  end 
 
  def send_redemption_link user
    # 6 character code is being generated/stored against auth token and packageId
    stored_url=Administration::StoredUrl.new
    code=stored_url.get_link_code(self.id, user.auth_token)

    if !code.nil?
      link="http://#{ApplicationController::SITE_URL}/#{code}"
      #link="http://#{ApplicationController::SITE_URL}/mobile/packages/#{self.id}/#{user.auth_token}"
      subject_tags  ={:OFFERING_TITLE => self.offering.title,:PACKAGE_TITLE => self.title}
      body_tags ={:OFFERING_TITLE => self.offering.title,:OFFERING_DESCRIPTION => self.offering.description,:PACKAGE_TITLE => self.title,:PACKAGE_DESCRIPTION => self.description,:LINK => link}

      body= Administration::EmailTemplate.parse_body(body_tags, 3)
      subject= Administration::EmailTemplate.parse_subject(subject_tags, 3)
      recipient=user.email
      UserMailer.send_email_to(recipient, subject, body).deliver
      return true
    else
      return false
    end

  end


  
  def send_signup_link recipient_emails
    link="http://#{ApplicationController::SITE_URL}/signup/#{self.id}"
    subject_tags  ={:OFFERING_TITLE => self.offering.title,:PACKAGE_TITLE => self.title}
    body_tags ={:OFFERING_TITLE => self.offering.title,:OFFERING_DESCRIPTION => self.offering.description,:PACKAGE_TITLE => self.title,:PACKAGE_DESCRIPTION => self.description,:LINK => link}

    body= Administration::EmailTemplate.parse_body(body_tags, 2)
    subject= Administration::EmailTemplate.parse_subject(subject_tags, 2)

    UserMailer.send_email(recipient_emails, subject, body).deliver
  end

  def next_valid_date
    valid_date = self.package_rule.next_available_date(Time.now)
    next_date = nil
    if self.start_date.to_date <= valid_date.to_date  && self.end_date.to_date >= valid_date.to_date
      next_date = valid_date
    end
    next_date
  end
  def log_merchant_verification(response_message,user_id)
    event_log = EventLog.new
    event_log.event_class = "Administration::MerchantPackage"
    event_log.event_action = 3
    event_log.event_body = response_message
    event_log.user_id = user_id
    event_log.merchant_package_id = self.id
    event_log.save
  end
  def image_valid(uploaded_data)
        
  end
  def delete_images
     Administration::MerchantPackageImage.destroy_all(:merchant_package_id => self.id)
  end
  def get_link(auth_token)

    package_link = ""
    stored_url=Administration::StoredUrl.new
    code = stored_url.get_link_code(self.id,auth_token)
    if !code.nil?
      package_link = "\n http://#{ApplicationController::SITE_URL}/#{code}"
    end
    package_link
  end

  def get_member_signup_link(member_id)

    package_link = ""
    stored_url=Administration::StoredSignupUrl.new
    code = stored_url.get_link_code(self.id, member_id)
    if !code.nil?
      package_link = "\n http://#{ApplicationController::SITE_URL}/#{code}"
    end
    package_link
  end

  def get_access_code
    if self.access_code.nil?
      self.access_code=String.random_alphanumeric(6)
      self.save
    end
    return self.access_code
  end
end
