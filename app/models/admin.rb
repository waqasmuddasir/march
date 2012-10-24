class Admin < ActiveRecord::Base
  validates_presence_of :login, :password
  validates_confirmation_of :password
  validates_uniqueness_of :login
  validates_presence_of :password_confirmation, :message=>"password dose not match.."

  before_save :encrypt_password, :if => :has_passowrd?

 def encrypt_password
    return if password.blank?
    self.password = Digest::MD5.hexdigest(password)
  end

  def has_passowrd?
    !password.blank?
  end

  def self.authenticate(login, password)
    return Admin.find(:first, :conditions => ["login = ? AND password = ? ", login, Admin.encrypt_password(password)])
  end

 def self.encrypt_password(pwd)
    Digest::MD5.hexdigest(pwd)
 end

 def self.all
    return Admin.find(:all, :conditions => ["is_super = false"])
 end

end
