
class GroupChat < ActiveRecord::Base
include Utils

  def send_chat
    self.save
    user_group = self.get_user_group

    if user_group.nil?
      if has_left? and !is_rejoining?
        message="Ultra Vie: Sorry you are not a member of this group2."
        return reply_sender(message)
      else
        if !contents.index("#join").nil?
          return false
        end
      end
    end

    user_group = self.get_user_group

    if !user_group.nil?
      if user_group.validate_sender(self.sender)
        contents = self.contents.strip
    
        member= user_group.group_members.find_by_mobile(self.sender)

        
        if contents.index("#")==0 # if its a command then make it lowercase
          contents=contents.downcase
          if !contents.index("#join").nil?
            return self.join_member

          elsif !contents.index("#leave").nil?
            return self.leave_member

          elsif !contents.index("#block").nil?
            mobile=contents.gsub("#block","")
            mobile= strip_mobile!(mobile)
            
            if !mobile.nil?
              return self.block_member mobile
            else
              message="Ultra Vie: Hey #{member.name}, to block your friend type #block <mobile>. You have sent an invalid mobile number."
              return reply_sender(message)
            end

          elsif !contents.index("#unblock").nil?
            mobile=contents.gsub("#unblock","")
            mobile= strip_mobile!(mobile)

            if !mobile.nil?
              return self.unblock_member mobile
            else
              message="Ultra Vie: Hey #{member.name}, to Unblock your friend, type #unblock <mobile>. You have sent an invalid mobile number."
              return reply_sender(message)
            end
            

          elsif !contents.index("#invite").nil?

            invitee=extract_name_from_sms!("#invite")
            mobile= extract_mobile_from_sms!("#invite")

            if !mobile.nil? and !invitee.blank?
                return self.invite_member invitee, mobile
            else
              message = "Ultra Vie: Hey #{member.name}, to invite your friend, type #invite <name> <mobile>.  You have entered an invalid "
              message = message + " Mobile number." if mobile.nil?
              message = message + " Member Name (should be between 3 to 15 characters). " if invitee.nil?
              return reply_sender(message)
            end


      
          elsif !contents.index("#help").nil?
            return self.send_help_sms


          elsif !contents.index("#info").nil?
            return self.send_info_sms
          else
            message="Ultra Vie: Hey #{member.name}, you have sent an invalid command.  For list of all valid commands, text #help."
             return reply_sender(message)#incase of a wrong hash command
            
          end
        else
          return forward_message
        end

      else
        return false
      end
    end
  end


  def extract_mobile_from_sms! cmd
    text= self.contents
    text=text.gsub(cmd,"")
    contents=text.split(" ")
    mobile=""

    contents.each do |c|
      txt=mobile_remove_extra_bits(c)
      txt=all_digits?(txt)
      mobile=mobile+txt.to_s if !txt.nil?
    end

    mobile= mobile_add_code mobile if !mobile.nil?

    return mobile
  end

  def extract_name_from_sms! cmd
    text= self.contents
    text=text.gsub(cmd,"")
    contents=text.split(" ")
    name=""

    contents.each do |c|
      txt=mobile_remove_extra_bits(c)
      txt=all_digits?(txt)
      name=name + " " + c if txt.nil?
    end
    name=nil if name.length<2 or name.length>15

    return name
  end

  
  def forward_message
    
    sms_sent = false
    user_group = self.get_user_group
    
    if !user_group.nil?
      user_group.auto_activate_sender(self.sender)#Auto activation on reply/chat

      group_member= user_group.get_member(self.sender)

      if !group_member.nil?
        message=group_member.name + " says: "+self.contents
      else
        owner= User.find_by_mobile(self.sender)
        if !owner.nil?
          message=owner.name + " says: "+self.contents
        else
          message=self.contents
        end

      end

      user_group.send_chat_sms(message,self.sender)
      self.user_group_id = user_group.id
      self.save
      sms_sent = true
    end
    sms_sent
  end

  def send_help_sms
    return nil if self.sender.nil?
    txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
    api_response = ""
    if !txtlocal.nil?
      user_group = self.get_user_group

      if !user_group.nil? and user_group.is_group_admin? self.sender
        txtlocal.message_contents="Ultra Vie: Group Chat Help. Send text: #join to join or re-join a group; #leave to leave a group; #info for a list of current group members; #invite <name> <mobile> to invite a member. Creator only: #block or #unblock <mobile> to block/unblock a member."

      else
        txtlocal.message_contents="Ultra Vie: Group Chat Help. Send text: #join to join or re-join a group; #leave to leave a group; #info for a list of current group members; #invite <name> <mobile> to invite a member."
      end
      api_response = txtlocal.send_group_chat_sms(self.in_number, self.sender)
    end
    api_response
    
  end

  def send_info_sms
    
    return nil if self.sender.nil?
    return nil if self.in_number.nil?

    mobile=  strip_mobile!(self.sender)
    user_group = self.get_user_group
    message_content=""
    if !user_group.nil?
      txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
      api_response = ""
      if !txtlocal.nil?
        message_content="Ultra Vie: "
        message_content=user_group.get_member_list(mobile)
        txtlocal.message_contents=message_content        
        api_response = txtlocal.send_group_chat_sms(self.in_number, self.sender)
      end
      api_response
    end
  end

  def block_member mobile
    user_group = self.get_user_group
    if !user_group.nil?
      if user_group.is_group_admin? self.sender
        user_group.block_this_member mobile
      else
        reply_sender("Ultra Vie: #block & #unblock commands can only be used by the creator of the group.")
      end
    end

  end

  def unblock_member mobile
    user_group = self.get_user_group
    if !user_group.nil?
      if user_group.is_group_admin? self.sender
        user_group.unblock_this_member mobile
      else
        reply_sender("Ultra Vie: #block & #unblock commands can only be used by the creator of the group.")
      end
    end

  end

  def join_member
    user_group = self.get_user_group
    user_group.join_member self.sender if !user_group.nil?
  end



  def leave_member
    user_group = self.get_user_group
    if !user_group.nil?
      if user_group.is_group_admin? self.sender
        reply_sender("You cannot Leave this group as you are the creator. to delete the entire group, please login to website")
      else
        user_group.leave_member self.sender 
      end
    end

  end

  

  def invite_member name, mobile
    user=User.find_by_mobile(self.sender)
    
    if user.nil?
      user = User.new
      user.mobile = self.sender
    end
    user_group = self.get_user_group

    if !user_group.nil?
      
      package=Administration::MerchantPackage.find(user_group.package_id)
      
      if !package.nil?
        
        group_member = GroupMember.new
        group_member.name =name
        group_member.mobile=mobile
        group_member.package_id=user_group.package_id
        group_member.user_group_id=user_group.id
        
        if !user_group.member_exists?(mobile)
          return group_member.invite_user(user)
        elsif user_group.member_limit_exceeds?
          message="Ultra Vie: No more users can be invited to this group."
          return user.send_sms_from_group(user_group.id, message)
        else
          message="Ultra Vie: #{name} is already a member of this group."
          return user.send_sms_from_group(user_group.id, message)
        end
      end
    end
    return false
  end


  def get_user_group

    return nil if self.sender.nil?
    return nil if self.in_number.nil?

    user_group=nil

    phone_number=self.in_number
    group_members = GroupMember.find_all_by_mobile(self.sender)
    group_number=GroupNumber.find_by_phone_number(phone_number)
    if group_number.nil?
      return nil
    end

    number_id = group_number.id

    group_members.each do |gm|
      if gm.group_number_id==number_id
        user_group=UserGroup.find(gm.user_group_id)
      end
    end    

    # For Owner
    if user_group.nil?
      user= User.find_by_mobile(self.sender)
      if !user.nil?
        user_groups=UserGroup.find_all_by_user_id(user.id)
        user_groups.each do |ug|
          if ug.group_number_id==number_id
            user_group=ug
          end
        end

      end

    end

    return user_group

  end


  def get_package_group

    return nil if self.sender.nil?
    return nil if self.in_number.nil?

    user_group=nil

    group_members = GroupMember.find_all_by_mobile(self.sender)
    number_id=GroupNumber.find_by_phone_number(self.in_number).id
    
    sender_group_member_rec=nil # for getting package_Id

    group_members.each do |gm|
      group = UserGroup.find(gm.user_group_id)
      if group.group_number_id==number_id
        user_group=UserGroup.find(gm.user_group_id) #Group through which it connect to the package
        sender_group_member_rec=gm # for getting package_Id
      end
    end

    if !user_group.nil?
      #all groups of group owner

      group_owner_groups=UserGroup.find_all_by_user_id(user_group.user_id)

      group_owner_groups.each do |gog|
        gog.group_members.each do |gogm|
          if gogm.package_id==sender_group_member_rec.package_id
            #Here we send text------------------
          end
        end
      end
    else
      # For Owner
      group_owner=User.find_by_mobile(sender)

      group_owner_groups=UserGroup.find_all_by_user_id(group_owner.id)

    end
  end

  def is_rejoining?

    left_member=GroupMemberLeave.find_all_by_mobile(self.sender)
    group_number=GroupNumber.find_by_phone_number(self.in_number)
    if group_number.nil?
      return false
    end
    in_number_id = group_number.id

    left_member.each do |m|
      if m.group_number_id == in_number_id
          user_group=UserGroup.find(m.user_group_id)
          user_group.rejoin_member self.sender if !user_group.nil?
          return true
      end
    end
    return false
  end
  def has_left?
    left_member=GroupMemberLeave.find_all_by_mobile(self.sender)
    left_member.count == 0 ? (return false) : (return true)
  end
  def send_invalid_mobile_error_sms!
  return reply_sender "Ultra Vie: Please provide a valid mobile number."
  end

  def reply_sender message
    return nil if self.sender.nil?
    txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
    api_response = ""
    if !txtlocal.nil?
      txtlocal.message_contents=message
      api_response = txtlocal.send_group_chat_sms(self.in_number, self.sender)
    end
    api_response

  end

end
