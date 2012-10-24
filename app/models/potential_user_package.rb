class PotentialUserPackage < ActiveRecord::Base
  belongs_to :potential_user
  belongs_to :merchant_package, :class_name=> "Administration::MerchantPackage"

  def self.create_by_ids package_id, user_id
      user_package=PotentialUserPackage.new
      user_package.potential_user_id=user_id
      user_package.merchant_package_id=package_id
      user_package.is_subscribed=0
      user_package.save
  end

  def self.find_all_by_user_email email
    user = PotentialUser.find_by_email(email)
    return PotentialUserPackage.find_all_by_potential_user_id(user.id)
  end
end
