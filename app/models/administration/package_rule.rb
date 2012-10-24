class Administration::PackageRule < ActiveRecord::Base
  validate :validate_times

  belongs_to :merchant_package
  has_one :package_allowed_time
  accepts_nested_attributes_for :package_allowed_time ,:allow_destroy => true  
  RULETYPE = [["None", "none"],
    ["Week days", "weekly"],
    ["Monthly", "monthly"],
    ["Yearly", "yearly"]
  ]
  DAYS = [["Monday","1"],["Tuesday","2"],["Wednesday","3"],["Thursday","4"],["Friday","5"],["Saturday","6"],["Sunday","7"]]

  def validate_times
    if self.start_time && self.end_time && !self.is_all_day
      if(self.start_time.to_time >= self.end_time.to_time) || (self.package_allowed_time.start_time.to_time >= self.package_allowed_time.end_time.to_time)
        errors.add_to_base("Invalid end time.")
      end
      if(self.package_allowed_time.start_time.to_time <= self.end_time.to_time)
        errors.add_to_base("Invalid 2nd timestamp")
      end
    end
  end
  def days
    weekdays = []
    rule_json = JSON.parse(self.rule) rescue nil
    if !rule_json.nil? && rule_json[0]["rule"][0]["weekly"][0]["valid"]
      selected_days = rule_json[0]["rule"][0]["weekly"][0]["days"]
      weekdays = selected_days.split(",") rescue nil
    end
    weekdays
  end
  def is_valid(current_date)
    valid = false   

    if self.rule == "none"
      valid = true
    end
    rule_json = JSON.parse self.rule rescue nil
    if !rule_json.nil?       
      
      is_week = rule_json[0]["rule"][0]["weekly"][0]["valid"]
      is_year = rule_json[0]["rule"][0]["yearly"][0]["valid"]
      is_month = rule_json[0]["rule"][0]["monthly"][0]["valid"]
      if is_week
        if !self.days.nil? && self.days.include?(current_date.wday.to_s)
          valid = true
        end
      elsif is_year
        day = rule_json[0]["rule"][0]["yearly"][0]["day"].to_i
        month = rule_json[0]["rule"][0]["yearly"][0]["month"].to_i
        if(day == current_date.mday.to_i && month == current_date.month.to_i)
          valid = true
        end
      elsif is_month
        day = rule_json[0]["rule"][0]["monthly"][0]["day"].to_i
        if(day == current_date.mday.to_i)
          valid = true
        end
      end
    end
  all_day_rule = false
    # CHECK IF PACKAGE IS AVAILABLE ALL DAY OR JUST FOR FEW HOURS
    if !self.is_all_day
      current_hour = current_date.hour
      if(self.start_time.hour <= current_hour && self.end_time.hour >= current_hour) || (self.package_allowed_time.start_time.hour <= current_hour && self.package_allowed_time.end_time.hour >= current_hour)
        all_day_rule = true
      end
    elsif self.is_all_day
        all_day_rule = true
    end
    if all_day_rule && valid
      valid = true
    else
      valid = false
    end
    valid
  end
  def next_available_date(current_date)
    tomorrow_date = current_date + 1.day
    next_date = tomorrow_date
    day = "";
    rule_json = JSON.parse self.rule rescue nil
    if !rule_json.nil?
       is_week = rule_json[0]["rule"][0]["weekly"][0]["valid"]
       if is_week
         if !self.days.nil?
           if self.days.include?(tomorrow_date.wday.to_s)
                 day = "Tomorrow"
                 next_date = current_date + 1.day
           else
            self.days.each do |d|
              if d.to_i > current_date.wday.to_i
                day = d
                next_date = calculate_next_date(day.to_i)
              end
            end
           end
           if day == ""
             day = self.days[0]
             next_date = calculate_next_date(day.to_i)
           end
          end
       end
       
       is_year = rule_json[0]["rule"][0]["yearly"][0]["valid"]
       is_month = rule_json[0]["rule"][0]["monthly"][0]["valid"]
    end
     next_date

  end
  protected
  def calculate_next_date(to_day)
    current_day = Time.now.wday
    next_date = Time.now
    if current_day > to_day
      dif = current_day - to_day
      next_week = Time.now  + 1.week
      next_date = next_week - dif.day
    else
      dif = to_day - current_day
      next_date = Time.now + dif.day
    end
    next_date
  end
end
