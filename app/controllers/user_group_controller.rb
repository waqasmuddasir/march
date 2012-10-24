class UserGroupController < ApplicationController
  before_filter :login_required
  before_filter :prepare_data, :only=>[:index, :edit_name, :invite_member]
   
  layout 'users'
  include AuthenticatedSystem
  include Utils


  def index
    @groups=UserGroup.find_all_by_user_id(current_user.id)
  end

  def send_invitation_test
    group_member = GroupMember.new
    group_member.name = "Nasir"
    group_member.mobile = "923214211852"
    group_member.package_id = 1
    if group_member.invite_user(current_user)
      render :text => "added"
    else
      render :text => "not added"
    end
  end

  def send_invitation
    if !current_user.mobile.nil? and !current_user.mobile.blank?
      @group_member = GroupMember.new(params[:member])
      if @group_member.valid?
        @group_member.mobile = strip_mobile!(@group_member.mobile)

        if @group_member.invite_user(current_user)
          flash[:notice] = "Your invitation has been sent"
        else
           if !@group_member.error.blank?
            flash[:error] = @group_member.error
          else
            flash[:error] = "Sorry we could not send invitation to #{params[:member][:name]} ."
          end
        end

      else
        @package_id = params[:member][:package_id]
        @package = Administration::MerchantPackage.find(params[:member][:package_id])
        @user_package = UserPackage.find(:first,:conditions => {:merchant_package_id => params[:member][:package_id],:user_id => current_user.id})

        
      end
    else
      flash[:error] = "Please provide your Mobile number before sending invitations.."
      
    end

    redirect_to :action => "index"
  end


  def remove_member
    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])
      if !group_member.nil?
        group_member.destroy
      end

    end

    redirect_to :action => "index"

  end

  def block_member
  
    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])
  
      if !group_member.nil?
        #group_member.is_blocked = true
        #group_member.save
        user_group=UserGroup.find(group_member.user_group_id)
        user_group.block_this_member(group_member.mobile)
        flash[:notice] = "#{group_member.name} has been blocked"
      end
    end

    redirect_to :action => "index"
  end
  def unblock_member
    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])
      if !group_member.nil?
        #group_member.is_blocked = false
        #group_member.save
        user_group=UserGroup.find(group_member.user_group_id)
        user_group.unblock_this_member(group_member.mobile)

        flash[:notice] = "#{group_member.name} has been Unblocked"
      end
    end

    redirect_to :action => "index"
  end

  def delete_member

    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])

      if !group_member.nil?
        n=group_member.name
        GroupMember.delete_all(:id => params[:member_id])
        flash[:notice] = "#{n} has been Deleted"
      end
    end

    redirect_to :action => "index"
  end

  def rejoin_member

    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])

      if !group_member.nil?
        group = UserGroup.find(group_member.user_group_id)
        n=group_member.name
        flash[:error] = "#{n} is already in the group #{group.name}!"
      else
        left_member = GroupMemberLeave.find_by_id(params[:member_id])
        if !left_member.nil?
          user_group = UserGroup.find(left_member.user_group_id)
          has_rejoined =false
          has_rejoined = user_group.rejoin_member(left_member.mobile) if !user_group.nil?
          
          
          if has_rejoined
            
            flash[:notice] = "You have rejoined the group #{user_group.name}"
          else
            flash[:error] = "Sorry you cannot rejoined the group #{user_group.name}"
          end
        end
      end
    end

    redirect_to :action => "index"
  end


  def remove_owner

    if !params[:group_id].nil?

      user_group = UserGroup.find(params[:group_id])

      if !user_group.nil?
        GroupMember.delete_all(:user_group_id => params[:group_id])
        UserGroup.delete_all(:id => params[:group_id])
      end
    end
    redirect_to :action => "index"
  end


  def join_group
    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])
      if !group_member.nil?
        group_member.is_active = true
        group_member.save
      end
    end
    redirect_to :action => "index"
  end

  def update_name
    user_group= UserGroup.find(params[:id])
    
    if !user_group.nil?
      user_group.name = params[:group_name]
      user_group.save
    end
    redirect_to :action=>:index
  end

  def edit_name
    @groups=UserGroup.find_all_by_user_id(current_user.id)    
    @edit_group_id= params[:id]

    render :action=>:index
  end

  def invite_member
    @groups=UserGroup.find_all_by_user_id(current_user.id)    
    @invite_group_id= params[:id]
    group=UserGroup.find(params[:id])
    @package=Administration::MerchantPackage.find(group.package_id )
    @member=GroupMember.new
    render :action=>:index
  end


  def leave_group
    if !params[:member_id].nil?
      group_member = GroupMember.find_by_id(params[:member_id])
      if !group_member.nil?
        user_group=UserGroup.find(group_member.user_group_id)
        user_group.leave_member(group_member.mobile)
      end
    end
    redirect_to :action => "index"
  end

  private

  #before filter
  def prepare_data
    @invitations = current_user.group_invitations
    @joined_groups = current_user.joined_groups
    @left_groups=current_user.left_groups  
  end
end
