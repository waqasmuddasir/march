class PotentialUserEmailRecord < ActiveRecord::Base
  belongs_to :potential_user
  belongs_to :email_record

  def self.create_by_ids email_id, user_id
      user_email_record=PotentialUserEmailRecord.new
      user_email_record.email_record_id=email_id
      user_email_record.potential_user_id=user_id
      user_email_record.save
  end

end
