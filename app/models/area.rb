class Area < ActiveRecord::Base
  has_many :potential_users

  def self.find_or_create(areas)
    if self.find_by_name(areas[:name]).nil?
      self.new(areas).save
    end
  end
  def get_potential_user_emails
    potential_users=self.potential_users.all
    csv=""
    i=1;
    potential_users.each do |pu|
      csv=csv+pu.email
      csv=csv+", " if i<potential_users.count
      i=i+1
    end
    return csv
  end
  
end
