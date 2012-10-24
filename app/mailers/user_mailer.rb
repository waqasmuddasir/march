class UserMailer < ActionMailer::Base
  include AuthenticatedSystem

  def signup_notification(user)
    setup_email(user)    
    @subject = "Sign up notification for project-x.com"
    @signup_link="http://#{ApplicationController::SITE_URL}/"
    @url  = "http://#{ApplicationController::SITE_URL}/"
  end
  
  def activation(user)
      setup_email(user)
      @subject    += 'Your account has been activated!'
      @url  = "http://#{ApplicationController::SITE_URL}/"
  end
  
  def send_email(recipient, subject, body )
    @subject= "#{subject}"
    #@recipients= "#{recipient}"
    @bcc= "#{recipient}"
    @from = ApplicationController::ADMINEMAIL
    @body= "#{body}"
    @content_type="text/html"
  end

   def send_email_to(recipient, subject, body )
    @subject= "#{subject}"
    @recipients= "#{recipient}"
    #@bcc= "#{recipient}"
    @from = ApplicationController::ADMINEMAIL
    @body= "#{body}"
    @content_type="text/html"
  end

  def send_email_with_cc(recipient, cc, subject, body )
    @subject= "#{subject}"
    @recipients= "#{recipient}"
    @cc= "#{cc}"
    @from = ApplicationController::ADMINEMAIL
    @body= "#{body}"
    @content_type="text/html"
  end
  def forgot_password(user)    
    setup_email(user)    
    @subject    = 'You have requested to change your password'
    @body[:url]  = "http://#{ApplicationController::SITE_URL}/new_password/#{user.password_reset_code}"
  end

   protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = ApplicationController::ADMINEMAIL
    #@subject     = "[#{SITE_URL}]"
    @sent_on     = Time.now
    @user = user
    @content_type="text/html"
  end

 

end
