class GroupNumber < ActiveRecord::Base
has_many :user_groups

  def self.find_or_create(group)
    if self.find_by_phone_number(group[:phone_number]).nil?
      self.new(group).save
    end
  end
end
