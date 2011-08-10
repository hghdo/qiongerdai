class Device < ActiveRecord::Base
  
  def usage_str=(str)
    recent_usage=str
    count=str.each_char.inject(0){|sum,c| sum+=c.to_i}
    recent_using_frequency=count.to_f/str.length
    totally_usage+=count
    average_using_frequency=new_record? ? recent_using_frequency : (totally_usage/days_since_installation)
  end
  
  def from_str=(str)
    return unless new_record?
    installed_at=Time.parse(str)
  end
  
  private
  
  def days_since_installation
    (Time.now-installed_at)/3600/24
  end
  
  
end
