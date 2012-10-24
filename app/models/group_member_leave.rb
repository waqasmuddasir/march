class GroupMemberLeave < ActiveRecord::Base

def self.create_copy member_id
  group_member=GroupMember.find(member_id)
  
  if !group_member.nil?

  member_left=GroupMemberLeave.new
  member_left.id =group_member.id
  member_left.user_group_id =group_member.user_group_id
  member_left.mobile =group_member.mobile
  member_left.name =group_member.name
  member_left.package_id =group_member.package_id
  member_left.host_user_id =group_member.host_user_id
  member_left.group_number_id =group_member.group_number_id
  member_left.is_active =group_member.is_active
  member_left.is_blocked =group_member.is_blocked
  member_left.save
  return member_left
  else
    return nil
  end
end

def rejoin 
  
  group=UserGroup.find(self.user_group_id)
  group_count = GroupMember.find_all_by_mobile(self.mobile).count
  user=User.find_by_mobile(self.mobile)

  group_count = group_count + user.user_groups.count if !user.nil?
  
  if group.group_members.count<10 and group_count<5
    group_member=GroupMember.new

    group_member.id =self.id
    group_member.user_group_id =self.user_group_id
    group_member.mobile =self.mobile
    group_member.name =self.name
    group_member.package_id =self.package_id
    group_member.host_user_id =self.host_user_id
    group_member.group_number_id = group_member.matching_available_number(self.group_number_id)
    group_member.is_active =self.is_active
    group_member.is_blocked =self.is_blocked
    group_member.save

    GroupMemberLeave.delete_all(:id => self.id)
    return group_member
  else
    return nil
  end

end

end
