class AboutUsMessage < Ipcontent
  has_one :ip, :foreign_key=>:ipcontent_id
  validates_presence_of :message
  after_destroy :remove_message_file
  after_save :create_message_file

  def create_message_file    
    if File.exists?("#{message_file_name}")
      file = File.open("#{message_file_name}", "w")
    else
      file = File.new("#{message_file_name}", "w")
      #system("svn add #{message_file_name}")
    end
    file.write(@message)
    file.close
    #system("svn ci #{message_file_name} -m \" a custome about us message is added/updated with name #{message_file_name}\"")
  end
  
  def remove_message_file
    File.delete(message_file_name)
    #system("svn delete #{message_file_name}")
    #system("svn ci #{message_file_name} -m \"deleting #{message_file_name} on destroy\"")
  end

  def message_file_name
    path_prefix = "#{File.join(Rails.root,"app","views","ipcontent")}"
    return File.join("#{path_prefix}","_aboutus_message_#{self.id}.html.erb") unless self.id.blank?
  end

  def partial_path
    return File.join("/ipcontent","aboutus_message_#{self.id}") unless self.id.blank?
  end

  def message
    if self.new_record?
      @message
    elsif File.exists?("#{message_file_name}")
      file = File.open("#{message_file_name}", "r")
      @message = file.read
      file.close
      @message
    else
      file = File.new("#{message_file_name}", "w+")
      system("svn add #{message_file_name}")
      @message
    end
  end

  def message=(message)
    @message = message 
  end
end