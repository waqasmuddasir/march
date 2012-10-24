class GroupMember < ActiveRecord::Base
  belongs_to :user_groups
  belongs_to :users
  belongs_to :merchant_package

  validate :validate_data
  attr_accessor :error 
    

  def validate_data
    if name.blank?
      errors.add("Your Name", "missing..")
      return
    end
    if  name.length < 3
      errors.add("Your Name", "is too short")
      return
    end
    if   name.length > 150
      errors.add("Your Name", "is too long")
      return
    end

    if mobile.length < 10
      errors.add("mobile", "is invalid")
      return
    end

    if mobile.length > 13
      errors.add("mobile", "is invalid")
      return
    end


  end


#-------------------------------- Newly Added----------------------
  def invite_user(user)
    if user.mobile == self.mobile
      self.error = "Oops... It seems like you're trying to invite yourself."
      message= "Ultra Vie: "+self.error
      user.send_sms_from_group(self.user_group_id, message)
      return false
    end
    if self.check_multiple_group_membership user
      if !user.group_limit_exceeded && user.mobile != self.mobile

        invitee_available_numbers = invitee_available_numbers(self.mobile)

        self.error = "We are sorry but this user has exceeded his group joining limit" and return false if invitee_available_numbers.nil? or invitee_available_numbers.count == 0
        
        invitee_available=invitee_available_numbers.first

        self.group_number_id=invitee_available.id
        self.host_user_id=user.id

        
        if add_to_user_group(user)
          self.send_invitation_text(user)
          message="Ultra Vie: " + self.name + " has been invited to join your Group."
          user.send_sms_from_group(self.user_group_id, message)          
          return true
        else
          self.error = "No more users can be invited to this group."
         # return false

        end
      else
        self.error = "You cannot create more groups."
       # return false
      end
    else
      self.error = "#{self.name} (#{self.mobile}) is already a member of this group."
      #return false
    end

    if !self.error.blank?
      message= "Ultra Vie: "+self.error
      if !self.user_group_id.nil?
       user.send_sms_from_group(self.user_group_id, message)
      end
      return false
    end
  end

  
  #protected

  def check_multiple_group_membership invitee_user

    invited_members = GroupMember.find_all_by_mobile_and_package_id(self.mobile, self.package_id)
    return true if invited_members.nil? or invited_members.count == 0

    invitee_members = GroupMember.find_all_by_mobile_and_package_id(invitee_user.mobile, self.package_id)
    owned_groups=UserGroup.find_all_by_user_id(invitee_user.id)
    

    invited_members.each do |invited|
      if !invitee_members.nil?
        invitee_members.each do |invitee|
          return false if invited.user_group_id==invitee.user_group_id
        end
      end
      if !owned_groups.nil?
        owned_groups.each do |og|
          return false if og.id==invited.user_group_id
        end
      end
    end

    return true
  end

  def matching_available_number number_id

    available_numbers=invitee_available_numbers(self.mobile)
    return nil if available_numbers.count == 0
    
    available_numbers.each do |an|
      return  number_id if an.id==number_id
    end
    
    an=available_numbers.first
    return  an.id
  end

   def invitee_available_numbers(mobile)
    # Newly added 00000000000000
    joined_numbers = []
    # check for all joined groups
    joined_groups = GroupMember.find_all_by_mobile(mobile)
    if joined_groups.nil? || joined_groups.count == 0
      return GroupNumber.find(:all)
    end
    joined_groups.each do |group|
      joined_numbers << group.group_number_id if !group.group_number_id.nil?
    end

    #find if mobile number is registered

    user = User.find_by_mobile(mobile)
    if !user.nil?
      #list all created group by a user
      created_groups = UserGroup.find_all_by_user_id(user.id)
      if !created_groups.nil?
        created_groups.each do |group|
          joined_numbers << group.group_number_id
        end
      end
    end

    available_groups =  GroupNumber.find(:all,:conditions => ["id NOT IN (?)",joined_numbers])
    available_groups

  end


  def invitee_available_groups(mobile)
  #old methode000000000000000
    groups = []
    joined_numbers = []
    # check for all joined groups
    joined_groups = GroupMember.find_all_by_mobile(mobile)
    if joined_groups.nil? || joined_groups.count == 0
      return GroupNumber.find(:all)
    end
    joined_groups.each do |group|
      groups << group.user_group_id
    end
    #find if mobile number is registered
  
    user = User.find_by_mobile(mobile)
    if !user.nil?
      #list all created group by a user
      created_groups = UserGroup.find_all_by_user_id(user.id)
      if !created_groups.nil?
        created_groups.each do |group|
          joined_numbers << group.group_number_id
        end
      end
    end
    user_groups = UserGroup.find(:all,:conditions => {:id => groups})
    user_groups.each do |user_group|
      joined_numbers << user_group.group_number_id
    end
    available_groups =  GroupNumber.find(:all,:conditions => ["id NOT IN (?)",joined_numbers])
    available_groups
 
  end

  
  #-------------------------------- Newly Added----------------------

  def add_to_user_group(user)

    if !self.user_group_id.nil?
      user_group = UserGroup.find(self.user_group_id)
    else
      group_member = GroupMember.find(:first,:conditions => {:mobile => user.mobile,:package_id => self.package_id})
      if !group_member.nil?
        user_group = UserGroup.find(group_member.user_group_id) 
      else
        user_group  = UserGroup.find(:first,:conditions => {:user_id => user.id,:package_id => self.package_id})
      end
    end

   self.error = "Group members limit has been exceeded." and return false if !user_group.nil? and user_group.member_limit_exceeds?

    # incase if a member (not creator) of the group invite a person then the group exist in first place
# and cannot be nil
# a group can only be nil if the user is the owner of the group in which case its ok to have the user available numbers

    if user_group.nil?
        user_available_numbers = user.available_numbers
        return false if user_available_numbers.nil? or user_available_numbers.count == 0

        user_group = UserGroup.new
        user_group.group_number_id = user_available_numbers.first.id
        user_group.user_id=user.id
        user_group.package_id=self.package_id
        user_group.name = Administration::MerchantPackage.find(self.package_id).title
        user_group.save

    end
    
    
    existed_member=user_group.get_member(self.mobile)
    if existed_member.nil?
      user_group.group_members << self
      return true
     else

      self.error = self.name + " is already a member of this group."
      return false
    end
  end


  def assign_number(user,number_id)
    user_group = UserGroup.find(:first,:conditions => {:user_id => user.id,:group_number_id => number_id})
    if user_group.nil?
      user_group = UserGroup.new
      user_group.group_number_id = number_id
      user_group.user_id=user.id
      user_group.name = user.name+"_"+user.id.to_s+"_"+number_id.to_s
      user_group.save
    end    
    user_group.group_members << self
  end

  def send_invitation_text(user)
    txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_INVITATION)
    api_response = ""
    if !txtlocal.nil?
      package = Administration::MerchantPackage.find_by_id(self.package_id)
      registered = User.find_by_mobile(self.mobile)
      if !registered.nil?
        package_link = package.get_link(registered.auth_token)
        message = "Hi "+self.name+", your friend #{user.name} has also signed up on Ultra to get #{package.title}. To redeem this offer, please visit this link: #{package_link}. \nTo chat with #{user.name} just reply to this message."
      else
        package_link = package.get_member_signup_link(self.id)
        message = "Hi "+self.name+", your friend #{user.name} has invited you to share an offer on Ultra to get #{package.title}. To redeem this offer, please visit this link: #{package_link}. \nTo chat with #{user.name} just reply to this message."
      end
      txtlocal.message_contents = message
      api_response = self.send_group_chat_sms message #txtlocal.send_sms(self.mobile)
    end
    api_response
  end
  
  def send_group_chat_sms message
    txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
    api_response = ""
    if !txtlocal.nil?
    #Group phone number will be different for every user
      group_number=GroupNumber.find(self.group_number_id)
      
      message=message.gsub("{MEMBER_NAME}", self.name)

      txtlocal.message_contents = message
      api_response = txtlocal.send_group_chat_sms(group_number.phone_number,self.mobile)
    end
    api_response
  end

  def is_active_unblock

    return false if !self.is_active
    return false if self.is_blocked
    return true
  end

  def join_group

    if !self.is_active
      self.is_active = true
      self.save

      user_group=UserGroup.find(self.user_group_id)

      message= "Hi {MEMBER_NAME}, you have now joined #{user_group.get_admin_name}'s group."
      return send_group_chat_sms message

    else

      message= "Ultra Vie: you are already a member of this group."
      send_group_chat_sms message 
        return false
    end


  end

  def leave_group
    GroupMember.delete_all(:id => self.id)
  end

  def unblock_from_group
    if self.is_blocked
      self.is_blocked=false
      self.save
      return true
    else
      return false
    end
  end

  def block_from_group
    if !self.is_blocked
      self.is_blocked=true
      self.save
      return true
    else
      return false
    end
  end

end
