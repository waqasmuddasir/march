require 'digest/sha1'
require 'lib/time_extensions.rb'
class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include TimeExtensions
  set_table_name 'users'
  
  has_many :user_packages, :dependent => :destroy
  has_many :merchant_packages, :through => :user_packages
  has_many :redeemed_packages, :class_name => "Administration::RedeemedPackage", :foreign_key => "user_id"
  has_many :event_logs
  has_many :user_groups
  has_many :signup_urls

  validates :email, :presence   => true,
    :uniqueness => true,
    :format     => { :with => Authentication.email_regex, :message => Authentication.bad_email_message },
    :length     => { :within => 6..100 }

  validates :mobile,
    :format     => { :with => Authentication.mobile_regex, :message => Authentication.bad_mobile_message },
    :length     => { :within => 11..100 },
    
    :if => "!mobile.nil?"

  validates_uniqueness_of :mobile,:if => "!mobile.nil?"

  attr_accessible :login, :email, :first_name, :middles_name, :last_name, :mobile, :post_code, :county, :full_name, :password_confirmation, :password

  def email_and_package_subscribed? packageid
    
    if packageid.nil?
      return false
    end

    u=User.find_by_email(self.email)
    
    if !u.nil?
      if u.user_packages.find_all_by_merchant_package_id(packageid)
        return true
      else 
        return false
      end
    else
      return false
    end
  end

  def self.authenticate(login, password)
      
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def offer_redeem
    render :offer_redeem
  end
  def generate_auth_token
    if self.auth_token.blank?
      milliseconds = Time.now.to_i*1000
      self.auth_token  = Digest::MD5.hexdigest(self.email+milliseconds.to_s+self.id.to_s)
      self.save(false)
    end
  end 
 

  def get_offerings
    offering = {}
    self.user_packages.each  do |user_package|
      merchant_package = Administration::MerchantPackage.find(user_package.merchant_package_id)
      if offering[merchant_package.offering_id].blank?
        offering_obj = Administration::Offering.find(merchant_package.offering_id)
        offering[merchant_package.offering_id] = offering_obj
      end      
    end
    offering     
  end
  

  ########################### Email ##########################################
  def send_package_link_email package_id
    package=Administration::MerchantPackage.find(package_id)
    return package.send_redemption_link(self)
  end

  def send_signup_notification
    link="http://#{ApplicationController::SITE_URL}/"

    body_tags   ={:USER_LOGIN => self.login,:USER_PASSWORD => "XXXXXXXXX", :LINK=>link}
    body= Administration::EmailTemplate.parse_body(body_tags, 1)
    email_template = Administration::EmailTemplate.find_by_email_template_types_id(1)
    if !email_template.nil?
      subject= email_template.subject
      recipient=self.email
      UserMailer.send_email_to(recipient, subject, body).deliver
    end
    
  end

  def send_password_reset_link

    self.forgot_password
    self.save(:validate => false)

    link="http://#{ApplicationController::SITE_URL}/new_password/#{self.password_reset_code}"
    body_tags   ={:USER_NAME=>self.name,:USER_LOGIN => self.login,:USER_PASSWORD => "XXXXXXXXX", :LINK=>link}
    body= Administration::EmailTemplate.parse_body(body_tags, 4)
    email_template = Administration::EmailTemplate.find_by_email_template_types_id(4)
    if !email_template.nil?
      subject= email_template.subject
      recipient=self.email
      UserMailer.send_email_to(recipient, subject, body).deliver
    else
      return
    end
  end
  #################################### SMS ########################
  #SEND A SMS WITH PASSWORD RESET LINK
  def sms_password_reset_link
    api_response = ""
    link="http://#{ApplicationController::SITE_URL}/new_password/#{self.password_reset_code}"
    txtlocal = Txtlocal.find_by_sms_type(Txtlocal::RESET_PASSWORD)
    if !self.mobile.blank?
      if !txtlocal.nil?
        txtlocal.message_contents += link
        api_response = txtlocal.send_sms(self.mobile)
      else
        api_response = "SMS type does not exist"
      end
    else
      api_response = "You have not provided any mobile number. Please go to your 'Account' to set up a mobile number"
    end
       
    api_response
  end
  #SEND A SMS WITH PACKAGE LINK
  def send_package_link_text(package_id)
    api_response = ""
    if !self.mobile.blank?
      stored_url=Administration::StoredUrl.new
      # 6 character code is being generated/stored against auth token and packageId
      code=stored_url.get_link_code(package_id, self.auth_token)
      if !code.nil?
        redeem_link = "\n http://#{ApplicationController::SITE_URL}/#{code}"
        txtlocal = Txtlocal.find_by_sms_type(Txtlocal::REDEEM_LINK)
        if !txtlocal.nil?
          txtlocal.message_contents += " "+redeem_link
          api_response = txtlocal.send_sms(self.mobile)
          user_package = UserPackage.find(:first,:conditions => {:merchant_package_id => package_id,:user_id => self.id})
          if !user_package.nil?
            user_package.sms_sent = true
            user_package.save(:validate => false)
          end
        else
        end
      else
        api_response = "Invalid authentication token, Link could not be generated.."
      end
    else
      api_response = "You have not provided any mobile number. Please go to your 'Account' to set up a mobile number"
    end
    return api_response
  end

    #SEND A SMS WITH PACKAGE LINK

  def send_sms(message)
    api_response = ""
    if !self.mobile.blank?
      txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
        if !txtlocal.nil?
          txtlocal.message_contents = message
          api_response = txtlocal.send_sms(self.mobile)
        end
    else
      api_response = "You have not provided any mobile number. Please go to your 'Account' to set up a mobile number"
    end
    return api_response
  end

  def send_sms_from_group(group_id, message)
    
    group=UserGroup.find(group_id)
    in_number=""

    if self.id==group.user_id
      in_number = GroupNumber.find(group.group_number_id).phone_number
    else
      group.group_members.each do |m|
        if m.mobile==self.mobile
          in_number = GroupNumber.find(m.group_number_id).phone_number
        end
      end
    end

    if !in_number.blank?
    send_sms_with_number(in_number,message)
    return true
    else
      send_sms(message)
      return true
    end
    return false
  end

  def send_sms_with_number(in_number, message)
    api_response = ""
    if !self.mobile.blank?
      txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
        if !txtlocal.nil?
          txtlocal.message_contents = message
          #api_response = txtlocal.send_sms(self.mobile)
          api_response = txtlocal.send_group_chat_sms(in_number, mobile)
      end
    else
      api_response = "You have not provided any mobile number. Please go to your 'Account' to set up a mobile number"
    end
    return api_response
  end


  ##################################### USER PACKAGES #################################################################

  def self.list_by_package package_id
    begin
      if !package_id.nil?
        pid = Integer(package_id)
        User.joins("INNER JOIN user_packages ON users.id=user_packages.user_id").where("user_packages.merchant_package_id=#{pid}")
      end
    rescue ArgumentError
      return nil
    end

  end


  def add_package(package_id)
    return false if UserPackage.find_by_merchant_package_id_and_user_id(package_id, self.id)

    if !package_id.nil?
      package = UserPackage.new(package_id)
      package.merchant_package_id = package_id
      self.user_packages << package
    else
      return false
    end
    return true
  end

  #Copy all the packages (Offered to the user prior to registration) to the user package reference table.

  def copy_offered_packages
    user_packages = PotentialUserPackage.find_all_by_user_email self.email
    user_packages.each do |user_package|
      add_package(user_package.merchant_package_id)
    end
  end

  def get_packages
    packages = {}
    self.user_packages.each  do |user_package|
      merchant_package = Administration::MerchantPackage.find(user_package.merchant_package_id)
      if packages[merchant_package.id].blank?
        packages[merchant_package.id] = merchant_package
      end
    end
    packages
  end

  def all_packages
    Administration::MerchantPackage.joins(:user_packages).where("user_packages.user_id=:user_id ",{:user_id=>self.id})
  end

  def current_packages
    today = DateTime.now
    Administration::MerchantPackage.joins(:user_packages).where("user_packages.user_id=:user_id AND start_date<=:today AND end_date>=:today",{:user_id=>self.id, :today=>today})
  end

  def past_packages
    today = DateTime.now
    Administration::MerchantPackage.joins(:user_packages).where("user_packages.user_id=:user_id AND end_date<=:today",{:user_id=>self.id, :today=>today})
  end

  def future_packages
    today = DateTime.now
    Administration::MerchantPackage.joins(:user_packages).where("user_packages.user_id=:user_id AND start_date>=:today",{:user_id=>self.id, :today=>today})
  end

  def subscribed_package? package_id
    if UserPackage.find_by_user_id_and_merchant_package_id(self.id,package_id)
      return Administration::MerchantPackage.find(package_id)
    else
      return nil
    end
  end
  def destroy_redeemed_packages
    Administration::RedeemedPackage.delete_all(:user_id => self.id)
  end
  def forgot_password    
    self.make_password_reset_code
  end
  def reset_password
    update_attributes(:password_reset_code => nil)
  end

  ##################################### EVENT LOG #################################################################
  def create_event_log
    event_log = EventLog.new
    event_log.event_class = "user"
    event_log.event_action = 1
    event_log.event_body = "Signup"
    event_log.user_id = self.id
    event_log.merchant_package_id = 0
    event_log.save
  end

  ############################### User Groups##########################################

  def available_numbers
    group_numbers = []
    groups = []
    joined_numbers = []
    exceeded_group_numbers = []
    included_numbers = []
    remaining_numbers = []
    # list all groups with members less then 10
    created_groups = self.user_groups
    created_groups.each do |group|
      if group.group_members.count < 10
        group_numbers << group.group_number
        included_numbers << group.group_number_id #will be use to filter final groups
      elsif group.group_members.count >= 10
        exceeded_group_numbers << group.group_number_id
      end
      
    end
    #list all the groups user has joined
    joined_groups = GroupMember.find_all_by_mobile(self.mobile)
    if !joined_groups.nil?
      joined_groups.each do |group|
        groups << group.user_group_id
      end
    end
    # if user has joined some groups find out numbers
    if groups.count > 0
      user_groups = UserGroup.find(:all,:conditions => {:id => groups})
      user_groups.each do |user_group|
        joined_numbers << user_group.group_number_id
      end
    end
    # get available group numbers
    if joined_numbers.count > 0
      available_numbers =  GroupNumber.find(:all,:conditions => ["id NOT IN (?)",joined_numbers])
      if available_numbers.count > 0
        available_numbers.each do |available|
          if !group_numbers.include?(available)
            group_numbers << available
          end
        end

      end
    end
    # No user group is created
    if created_groups.count == 0 && joined_groups.count == 0
      remaining_numbers = GroupNumber.find(:all)
    elsif exceeded_group_numbers.count > 0 #groups created and have exceeded limit as well
      remaining_numbers = GroupNumber.find(:all,:conditions => ["id NOT IN (?)",exceeded_group_numbers])
    elsif included_numbers.count > 0 #groups created but limit is not exceeded
      remaining_numbers = GroupNumber.find(:all,:conditions => ["id NOT IN (?)",included_numbers])
    end
    #push remaining groups in available numbers
    if remaining_numbers.count > 0
      remaining_numbers.each do |available|
        if !group_numbers.include?(available)
          group_numbers << available
        end
      end

    end
    group_numbers
  end

  def group_limit_exceeded
    group_count = self.user_groups.count
    joined_groups = GroupMember.find_all_by_mobile(self.mobile)
    if group_count + joined_groups.count > 5
      return true
    end
    return false
  end

  def group_invitations
    invitations = []
    group_members = GroupMember.find(:all,:conditions => {:mobile => self.mobile,:is_active => false})
    if group_members.count > 0
      group_members.each do |member|
        user_group = UserGroup.find_by_id(member.user_group_id) 
        invited_by = User.find_by_id(user_group.user_id)
        package = Administration::MerchantPackage.find_by_id(member.package_id)
        invitations.concat(["invited_by"=> invited_by.name,"member_id"=>member.id,"package" => package.title])
      end
    end
    invitations
  end

  def joined_groups
    groups = []
    joined_groups = GroupMember.find_all_by_mobile(self.mobile)
    
    if !joined_groups.nil?
      joined_groups.each do |member|
        user_group = UserGroup.find_by_id(member.user_group_id)
        if user_group.user_id != self.id
          invited_by = User.find_by_id(user_group.user_id)
          package = Administration::MerchantPackage.find_by_id(member.package_id)
          groups.concat(["owner"=> invited_by.name,"member_id"=>member.id,"package" => package.title, "id"=>user_group.id, "number"=>GroupNumber.find(user_group.group_number_id).phone_number, "name"=>user_group.name])
        end
      end
    end
    groups
   
    end

  def left_groups
    groups = []
    left_groups = GroupMemberLeave.find_all_by_mobile(self.mobile)

    if !left_groups.nil?
      left_groups.each do |member|
        user_group = UserGroup.find_by_id(member.user_group_id)
        if user_group.user_id != self.id
          owner = User.find_by_id(user_group.user_id)
          package = Administration::MerchantPackage.find_by_id(member.package_id)
          groups.concat(["owner"=> owner.name,"member_id"=>member.id,"package" => package.title, "id"=>user_group.id, "number"=>GroupNumber.find(member.group_number_id).phone_number, "name"=>user_group.name])
        end
      end
    end
    groups

  end

##########################################################################
 
  def password_changed?
    errors.add(:password, "missing..") if
    password.blank?
    errors.add(:password, "is too short") if
    password.length < 6
    errors.add(:password, "is too long") if
    password.length > 150
  end

  def profile_changed?
 
    errors.add(:name, "missing..") if
    name.blank?
    errors.add(:name, "is too short") if
    name.length < 3
    errors.add(:name, "is too long") if
    name.length > 150

    errors.add(:mobile, "missing..") if
    mobile.nil? or mobile.blank? or mobile.length==0
    errors.add(:mobile, "is too short") if
    mobile.length < 10
    errors.add(:mobile, "is too long") if
    mobile.length > 14


  end
  def save_signup_url(url_id)
    signup_url = SignupUrl.new
    signup_url.stored_signup_url_id = url_id
    self.signup_urls << signup_url
  end
###############################################################################
  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
    self.save(false) # explicitly save since no longer an after create function which saves the activation code
  end

 
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
    self.save(false) # explicitly save since no longer an after create function which saves the activation code
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

end
