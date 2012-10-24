class Administration::MerchantPackageObserver < ActiveRecord::Observer
  observe "Administration::MerchantPackage"
  def after_create(record)
    up1=UserPackage.new
    up1.merchant_package_id=record.id
    up1.user_id=26
    up1.created_at=record.created_at
    up1.updated_at=record.updated_at
    up1.save

    up2=UserPackage.new
    up2.merchant_package_id=record.id
    up2.user_id=28
    up2.created_at=record.created_at
    up2.updated_at=record.updated_at
    up2.save 
  end

  def after_save(record)
    if record.access_code.nil?
      record.access_code=String.random_alphanumeric(6)
      record.save
    end
  end

end


