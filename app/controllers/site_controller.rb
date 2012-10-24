class SiteController < ApplicationController
  layout 'home'
  before_filter :detect_browser
  skip_before_filter :verify_authenticity_token

  def home
    @friend = ShareWithFriend.new
    @potential_user= PotentialUser.new
  end
    
  def signup
    @potential_user= PotentialUser.new    
    @friend = ShareWithFriend.new
    if request.post?
    params[:potential_user][:email] = params[:potential_user][:login]
    @potential_user= PotentialUser.new(params[:potential_user])
      success = @potential_user && @potential_user.save
      
      if success && @potential_user.errors.empty?
        @potential_user.send_welcome_email
        flash[:notice] = "Thanks for confirming your details - We will soon update on our exciting offers. "
        if params[:from_facebook] == "false"
          redirect_to :action => :home
        else
          if params[:fb_sig_page_id].blank?
            redirect_to "/facebook/canvas/"
          else
            render :partial=>"/facebook/show_alert_and_redirect", :locals=>{:url=>FACEBOOK_URL, :message=>flash[:notice]}            
          end
        end
        return
      else
        if params[:from_facebook].to_s == "true"
          
          if params[:fb_sig_page_id].blank?
            render "/faecebook/canvas/", :layout=>"facebook"
          else
            message="The following errors occured while processing your request.\\n"
            count=1
            @potential_user.errors.full_messages.each do |msg|
              message += "#{count}. #{msg} \\n"
              count += count+1
            end            
            render :partial=>"/facebook/show_alert_and_redirect", :locals=>{:url=>FACEBOOK_URL, :message=>message}            
          end
        else
          render :home
        end
        return
      end
    end    
  end

  def share_with_friend
     @user = User.new
     @friend = ShareWithFriend.new
    if request.post?
      @friend = ShareWithFriend.new(params[:share_with_friend])
      @friend.save
      
      @friend.share_with_friend_by_email(params[:share_with_friend][:message]) if @friend.errors.empty?
    end
    render :home
     
  end
end
