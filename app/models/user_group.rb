class UserGroup < ActiveRecord::Base
  belongs_to :group_number
  belongs_to :users
  has_many :group_members

 
  def send_chat_sms message,sender
    self.group_members.each do |m|
      if m.is_active_unblock && m.mobile != sender
        m.send_group_chat_sms message
      end
      
    end
    send_sms_to_owner message if !self.is_group_admin?(sender)
  end

def member_limit_exceeds?

    if self.group_members.count<10
    return false
  else
    return true
  end
end

  def get_member_info
    #group_number =GroupNumber.find(self.group_number_id)
    content=""
    content =  "Group name: " + self.name + ". Current members: " + get_admin_name+ ", "
    count=1
    self.group_members.each do |m|
      content = content + m.name + ", "
    count=count+1
    end
      space=10-count.to_i
    content =content + "(" + space.to_s + ") spaces left"
    return content
  end

  def get_member_list mobile
    #Newly added just to add (you) besides the member name who asked for the info
    content=""
    group_creator=User.find(self.user_id)
    

      if group_creator.mobile==mobile
          content =  "Group name: " + self.name + ". Current members: " + group_creator.name + " (you), "
      else
          content =  "Group name: " + self.name + ". Current members: " + group_creator.name + ", "
      end

    count=1
    self.group_members.each do |m|
      if m.mobile==mobile
          content = content + m.name + " (you), "
      else
          content = content + m.name + ", "
      end


      count=count+1
    end
      space=10-count.to_i
    content =content + "(" + space.to_s + ") spaces left"
    return content
  end

  def get_member mobile

    self.group_members.each do |m|
      if m.mobile==mobile
        return m
      end
    end
      
    return nil
  end

  def member_exists? mobile

    self.group_members.each do |m|
      return true if m.mobile==mobile
    end

    owner=User.find(self.user_id)
    return true if owner.mobile == mobile
    
    return false
  end


  def auto_activate_sender mobile
    members= self.group_members.all

    members.each do |m|
      if m.mobile==mobile
        if !m.is_active and !m.is_blocked
          self.join_member(mobile)
        end
      end
    end
  end

  def validate_sender mobile
    return true if is_group_admin? mobile

    members= self.group_members.all

    members.each do |m|

      if m.mobile==mobile
        if !m.is_blocked
          return true
        else
          admin = User.find(self.user_id).name
          message="Ultra Vie: You were blocked from this group by the #{admin}. your message has not been delivered."
          m.send_group_chat_sms(message)
        end
      end
    end

    return false
  end

  def is_group_admin? mobile
    user=User.find(self.user_id)
    if user.mobile==mobile
      return true
    else
      return false
    end
  end

  def get_admin_name
    user=User.find(self.user_id)
    return user.name
  end

  def join_member mobile
    update_member(mobile, 'join')
  end

  def leave_member mobile
    update_owner(mobile, 'leave')
  end

  def block_this_member mobile
    update_owner(mobile, 'block')
  end

  def unblock_this_member mobile
    update_owner(mobile, 'unblock')
  end


  def update_member mobile, action
    members= self.group_members.all
    mobile.strip!
    members.each do |m|

      if m.mobile == mobile

        if action.eql?('join')
          
          if m.join_group

            # Send messages to the owner and all the members
            new_member=m.name
            message1=  " Ultra Vie:  #{new_member} has joined the group." + get_member_info
            message2=  " Ultra Vie: Hi {MEMBER_NAME}, your friend #{new_member} has accepted your invitation. To chat with him/her, just send your message to this number."

            host_user=User.find(m.host_user_id)
            owner=User.find(self.user_id)

            if !owner.nil? and !host_user.nil? and owner.id==host_user.id
              send_sms_to_owner(message2)
            else
              send_sms_to_owner(message1)
            end

            self.group_members.each do |mm|
              if mm.is_active_unblock and mm.id!=m.id

                if !host_user.nil? and mm.mobile==host_user.mobile
                  mm.send_group_chat_sms message2
                else
                  mm.send_group_chat_sms message1
                end
              end
            end
          end
        end
      end

    end
  end

    def rejoin_member mobile
      left_member=GroupMemberLeave.find_all_by_user_group_id(self.id)
      mobile.strip!

      left_member.each do |m|
        if m.mobile == mobile
          rjm=m.rejoin
          if !rjm.nil?
            new_member= rjm.name
            message=  "#{new_member} has rejoined the group."
            send_sms_to_owner(message)

            message=  "you have now rejoined the group."
            rjm.send_group_chat_sms(message)
            return true
          else

            #you cannot rejoin
            message=  "Sorry you can't rejoin this group."
            send_sms_to_member(m.group_number_id, mobile, message)
          return false
          end
          
        end
      end
      return false
    end

    def update_owner mobile, action
      members= self.group_members.all
      mobile.strip!
      members.each do |m|

        if m.mobile == mobile
          if action=='block'

            if m.block_from_group
              message= "Ultra Vie: " + m.name + " has been Blocked. Their messages will no longer be delivered. To unblock, use #unblock <mobile>"
              return send_sms_to_owner message
            else
              message= "Ultra Vie: " + m.name + " is already Blocked. To unblock, use #unblock <mobile>"
              send_sms_to_owner message
              return false
            end
            
        
          elsif action=='unblock'
            if m.unblock_from_group
            message= "Ultra Vie: " + m.name +   " has been unblocked"
            send_sms_to_owner message
          
            message="Ultr Vie: You have now been unblocked and can send messages to the group."
            return m.send_group_chat_sms(message)
            else
              message= "Ultra Vie: " + m.name + " was not blocked."
              send_sms_to_owner message
              return false
            end
          elsif action=='leave'
            GroupMemberLeave.create_copy(m.id)
            m.leave_group


            message= "Ultra Vie: you have now left the group. you can rejoin anytime by texting #join or sending a messages to this number."
            m.send_group_chat_sms(message)
            #          send_sms_to_owner message
          end

        end
      end
    end

    def _block member
      if member.block_from_group
        message= "Ultra Vie: " + member.name + " has been Blocked. Their messages will no longer be delivered. To unblock, use #unblock <mobile>"
        return send_sms_to_owner message
      else
        message= "Ultra Vie: " + member.name + " is already Blocked. To unblock, use #unblock <mobile>"
        send_sms_to_owner message
        return false
      end
    end

    def _unblock member
      if member.unblock_from_group
        message= "Ultra Vie: " + member.name +   " has been unblocked"
        send_sms_to_owner message

        message="Ultr Vie: You have now been unblocked and can send messages to the group."
        return member.send_group_chat_sms(message)
      else
        message= "Ultra Vie: " + member.name + " was not blocked."
        send_sms_to_owner message
        return false
      end
    end

    
    def group_phone_number
      g=GroupNumber.find(self.group_number_id)
      return g.phone_number
    end


    private


    def send_sms_to_owner message
      txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
      api_response = ""
      if !txtlocal.nil?
        group_number=GroupNumber.find(self.group_number_id)
        user= User.find(self.user_id)
        message = message.gsub("{MEMBER_NAME}", user.name)
        txtlocal.message_contents = message
        api_response = txtlocal.send_group_chat_sms(group_number.phone_number, user.mobile)
      end
      api_response
    end

    def send_sms_to_member group_number_id, mobile, message
      txtlocal = Txtlocal.find_by_sms_type(Txtlocal::GROUP_CHAT)
      api_response = ""
      if !txtlocal.nil?
        group_number=GroupNumber.find(group_number_id)
        txtlocal.message_contents = message
        api_response = txtlocal.send_group_chat_sms(group_number.phone_number, mobile)

      end
      api_response
    end

  end
