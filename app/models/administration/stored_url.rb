class Administration::StoredUrl < ActiveRecord::Base

  def get_link_code package_id, auth_token    
    if !auth_token.nil? and !package_id.nil?
      _stored_url = Administration::StoredUrl.find_by_merchant_package_id_and_user_auth_token package_id, auth_token
      
      if _stored_url.nil?
        _stored_url=Administration::StoredUrl.new
        _stored_url.random_code=String.random_alphanumeric
        _stored_url.merchant_package_id=package_id
        _stored_url.user_auth_token=auth_token
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
