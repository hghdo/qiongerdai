class HourPreferUsage < ActiveRecord::Base
  
  
  def self.update_usage(str)
    usage=HourPreferUsage.last
    usage=HourPreferUsage.new if usage.blank? || usage.created_at+14.day<Time.now
    usage.one_am+=char2num(str[0])
    usage.two_am+=char2num(str[1])
    usage.three_am+=char2num(str[2])
    usage.four_am+=char2num(str[3])
    usage.five_am+=char2num(str[4])
    usage.six_am+=char2num(str[5])
    usage.seven_am+=char2num(str[6])
    usage.eight_am+=char2num(str[7])
    usage.nine_am+=char2num(str[8])
    usage.ten_am+=char2num(str[9])
    usage.eleven_am+=char2num(str[10])
    usage.twelve_am+=char2num(str[11])
    
    usage.one_pm+=char2num(str[12])
    usage.two_pm+=char2num(str[13])
    usage.three_pm+=char2num(str[14])
    usage.four_pm+=char2num(str[15])
    usage.five_pm+=char2num(str[16])
    usage.six_pm+=char2num(str[17])
    usage.seven_pm+=char2num(str[18])
    usage.eight_pm+=char2num(str[19])
    usage.nine_pm+=char2num(str[20])
    usage.ten_pm+=char2num(str[21])
    usage.eleven_pm+=char2num(str[22])
    usage.twelve_pm+=char2num(str[23])
    usage.save
  end
  
  def self.char2num(str_or_int)
    value=str_or_int.is_a?(String) ? str_or_int.ord : str_or_int
    value<58 ? value.chr.to_i : value-64+9
  end
  
  
  
end
