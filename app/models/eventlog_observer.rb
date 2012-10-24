class EventlogObserver < ActiveRecord::Observer
  observe "Administration::RedeemedPackage", "UserPackage"
  def after_create(record)
    Rails.logger.debug "EventlogObserver::after_create"
    @event_log = EventLog.new
    @event_log.event_class = record.class.to_s

    case @event_log.event_class
    when "UserPackage"
       @event_log.event_action = 1
       @event_log.event_body = "Signup"
      
    when "Administration::RedeemedPackage"
       @event_log.event_action = 2
       @event_log.event_body = "Redeemed package"
    else
      
    end   
    @event_log.user_id = record.user_id
    @event_log.merchant_package_id = record.merchant_package_id
    @event_log.save
  end  
end
