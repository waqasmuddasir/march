class Administration::StoredSignupUrl < ActiveRecord::Base

  def get_link_code package_id, member_id
    if !member_id.nil? and !package_id.nil?
     
      _stored_url = Administration::StoredSignupUrl.find_by_merchant_package_id_and_group_member_id package_id, member_id

      if _stored_url.nil?
        _stored_url=Administration::StoredSignupUrl.new
        _stored_url.random_code=String.random_alphanumeric
        _stored_url.merchant_package_id=package_id
        _stored_url.group_member_id=member_id
        _stored_url.save
        return _stored_url.random_code
      else
        return _stored_url.random_code
      end
    else
      return nil
    end
  end

  private
  def String.random_alphanumeric(size=6)
    (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
  end
end