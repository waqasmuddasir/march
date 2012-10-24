class UserPackage < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant_package

  validates_uniqueness_of :user_id, :scope => :merchant_package_id
end
