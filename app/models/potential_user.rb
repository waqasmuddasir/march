class PotentialUser < ActiveRecord::Base
  include Authentication
  has_many :potential_user_packages, :dependent => :destroy
  has_many :merchant_packages, :through => :potential_user_packages, :class_name=> "Administration::MerchantPackage"

  has_many :potential_user_email_records, :dependent => :destroy
  has_many :email_records, :through => :potential_user_email_records
  belongs_to :areas

  validate :validate_data


  def validate_data

    errors.add("Your Email", "missing..") if login.blank?
    errors.add("Your Email", "is too short") if  login.length < 3
    errors.add("Your Email", "is too long") if   login.length > 150

    errors.add("Your Email", "is in valid..") if !Authentication.email_regex.match(login)
    errors.add("Email", "already been added..") if PotentialUser.find_by_login(login)
    errors.add("Email", "is already a registered member..") if User.find_by_login(login)
  end


  def self.create_by_email email
        potential_user = PotentialUser.new
        potential_user.email=email
        potential_user.login=email
        potential_user.save
        return potential_user.id
  end

  def send_welcome_email
    link="http://#{ApplicationController::SITE_URL}/"

    body_tags   ={:NAME => self.name,:EMAIL => self.email, :LINK=>link}
    body= Administration::EmailTemplate.parse_body(body_tags, 6)
    email_template = Administration::EmailTemplate.find_by_email_template_types_id(6)

    if !email_template.nil?
      subject= email_template.subject
      recipient=self.email
      UserMailer.send_email_to(recipient, subject, body).deliver
    end

  end

  def inser_potential_user_email csv
    counter=0
    if !csv.empty?
       csv.each "," do |email|
         email=email.to_s.gsub("'","")
         email=email.to_s.gsub(",","")
         email=email.to_s.gsub('"',"")
         email=email.to_s.gsub(' ',"")
         potential_user = PotentialUser.new
         potential_user.email=email
         potential_user.login=email

         if potential_user.save
           counter=counter+1
         end
      end
     end
     return counter
  end
end
