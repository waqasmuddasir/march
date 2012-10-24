class EventLog < ActiveRecord::Base
  belongs_to :merchant_packages, :class_name => "Administration::MerchantPackage", :foreign_key => "merchant_package_id"
  belongs_to :users
  EVENT_KINDS = [1 => "singup",
                 2 => "redeemed",
                 3 => "verified deal" ]
  


def self.updater
  date_created=EventLog.maximum("created_at")
  @users= User.find_by_sql("SELECT u.id, u.name, u.created_at FROM users u LEFT JOIN `user_packages` up ON u.id=up.user_id WHERE up.user_id IS NULL AND u.created_at=#{date_created}")
end

end
