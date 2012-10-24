class Administration::RedeemedPackage < ActiveRecord::Base
  belongs_to :merchant_packages
  belongs_to :users

  def time_expired
    expired = true
    min = 15
    sec = 00
    valid_time = self.start_time + (min.minutes + sec.seconds)
    current_time = Time.now
    if current_time  <= valid_time && current_time <= valid_time
      expired = false
    end
    expired
  end
end
