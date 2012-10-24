class UserObserver < ActiveRecord::Observer
  def after_create(user)
    user.send_signup_notification
  end  
end
