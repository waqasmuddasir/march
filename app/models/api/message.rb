class Api::Message < ActiveRecord::Base

  def self.find_or_create(message)
    if self.find_by_code(message[:code]).nil?
      self.new(message).save
    end
  end
end
