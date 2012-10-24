module UserGroupHelper

  def list_group_members id
    GroupMember.find_all_by_user_group_id(id)
  end


  def group_contact_number group_id, mobile

    group=UserGroup.find(group_id)

       contant_number=  GroupNumber.find(group.group_number_id).phone_number

    group.group_members.each do |m|
      if m.mobile==mobile
    
        contant_number=  GroupNumber.find(m.group_number_id).phone_number if !m.group_number_id.nil?
      end
    end

    
    contant_number="+44" +contant_number.last(10)

    return contant_number

  end
end
