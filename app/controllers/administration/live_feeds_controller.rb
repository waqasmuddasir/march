class Administration::LiveFeedsController < ApplicationController
  before_filter :authorize_admin, :except => [:more_feeds,:view,:feed_count]
  before_filter :detect_browser
  before_filter :prepare_data, :only=>[:index, :feed_count]
  layout "administration/admin"
  def index
    
  end

  def view
    start = 0
    if !params[:start].nil?
      start =  params[:start]
    end
    @feeds = EventLog.find(:all,:limit => "5",:offset => start,:order => "created_at DESC")
    respond_to do |format|
      format.js {render(:partial => 'view_feeds', :layout => false)}
    end
  end
  def more_feeds
     start = 0
    if !params[:start].nil?
      start =  params[:start]
    end
    @more_feeds = EventLog.find(:all,:limit => "5",:offset => start,:order => "created_at DESC")
    respond_to do |format|
      format.js {render(:partial => 'more_feeds', :layout => false)}
    end
  end
  def generate_live_feeds
    @users = User.find(:all)
    @users.each do |user|
      user.user_packages.each do |user_package|
         event_log = EventLog.new
          event_log.event_class = "Administration::MerchantPackage"
          event_log.event_action = 1
          event_log.event_body = "Sign up"
          event_log.user_id = user.id
          event_log.merchant_package_id = user_package.merchant_package_id
          event_log.created_at = user_package.created_at
          
            event_log.save
          
          
      end
      Administration::RedeemedPackage.find_all_by_user_id(user.id).each do |redeemed|
        event_log = EventLog.new
          event_log.event_class = "RedeemedPackage"
          
          if redeemed.is_completed == true
            event_log.event_action = 1
            event_log.event_body = "Varification successful"
          else
            event_log.event_action = 2
            event_log.event_body = "Redeemed package"
          end

          event_log.user_id = user.id
          event_log.merchant_package_id = redeemed.merchant_package_id
          event_log.created_at = redeemed.created_at
        
            event_log.save
        
      end
    end
    render :text => "generated"
  end
  def feed_count    
    respond_to do |format|
      format.js {render(:partial => 'live_feed_count', :layout => false)}
    end
  end
  
  private
  def prepare_data
    start_date = Time.now.utc.beginning_of_day
    end_date = Time.now.utc.end_of_day    
    @today_signups = EventLog.count(:id,:conditions => {:event_action => 1,:created_at => start_date..end_date})
    @today_redemptions = EventLog.count(:id,:conditions => {:event_action => 2,:created_at => start_date..end_date})
    @today_verifications = EventLog.count(:id,:conditions => {:event_action => 3,:created_at => start_date..end_date})
    @total_signups = EventLog.count(:id,:conditions => {:event_action => 1})
    @total_redemptions = EventLog.count(:id,:conditions => {:event_action => 2})
    @total_verifications = EventLog.count(:id,:conditions => {:event_action => 3})
  end
end
