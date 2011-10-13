class Device < ActiveRecord::Base
  
  def usage_str=(str)
    self.recent_usage=str
    count=str.each_char.inject(0){|sum,c| sum+=HourPreferUsage.char2num(c)}
    logger.debug("AAAAAAAAAAA=> #{count}")
    self.recent_using_frequency=count.to_f/str.length
    logger.debug("BBBBBBBBBBBB=> #{recent_using_frequency}")
    self.totally_usage||=0
    self.totally_usage+=count
    self.average_using_frequency=new_record? ? recent_using_frequency : (totally_usage/days_since_installation)
  end  
  
  
  def days_since_installation
    d=(Time.now-installed_at)/3600/24
    d>1 ? d : 1
  end
  
end
