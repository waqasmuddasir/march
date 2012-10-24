class SignupUrl < ActiveRecord::Base
  belongs_to :users
  belongs_to :stored_signup_url, :class_name => "Administration::StoredSignupUrl", :foreign_key => "stored_signup_url_id"
end
