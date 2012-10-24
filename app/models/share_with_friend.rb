  class ShareWithFriend < ActiveRecord::Base
    validate :validate_data


    def validate_data

      errors.add("Your Name", "missing..") if sender_name.blank?
      errors.add("Your Name", "is too short") if  sender_name.length < 3
      errors.add("Your Name", "is too long") if   sender_name.length > 150

      errors.add("Your Friend's Name", "missing..") if friend_name.blank?
      errors.add("Your Friend's Name", "is too short") if  friend_name.length < 3
      errors.add("Your Friend's Name", "is too long") if   friend_name.length > 150

      errors.add("Your Friend_email", "missing..") if friend_email.blank?
      errors.add("Your Email","is missing..") if sender_email.blank?

      errors.add("Your Email", "is in valid..") if !Authentication.email_regex.match(sender_email)
      errors.add("Your Friend's Email", "is in valid..") if !Authentication.email_regex.match(friend_email)

      errors.add("Your Friend", "is already a registered member..") if User.find_by_login(friend_email)

    end



     def share_with_friend_by_email message
      link="http://#{ApplicationController::SITE_URL}/"

      body_tags   ={:SENDER_NAME => self.sender_name,:SENDER_EMAIL => self.sender_email, :FRIEND_NAME => self.friend_name,:FRIEND_EMAIL => self.friend_email, :MESSAGE => message, :LINK=>link}
      body= Administration::EmailTemplate.parse_body(body_tags, 5)
      email_template = Administration::EmailTemplate.find_by_email_template_types_id(5)
      if !email_template.nil?
        subject= email_template.subject
        recipient=self.friend_email
        cc=self.sender_email
        UserMailer.send_email_with_cc(recipient, cc, subject, body).deliver
      end

    end
  end
