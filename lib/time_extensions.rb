module TimeExtensions
  def milliseconds
    Time.now.to_i*1000
  end

  Time.send(:include, TimeExtensions)
end
