require 'nokogiri'
require 'open-uri'
require 'rmmseg'

#include RMMSeg

namespace :segment do
   desc "Extract segmentation from mysql"
   task :extract => :environment do
      RMMSeg::Dictionary.load_dictionaries
      index=0
      #Archive.all.each do | arc |      
      #    doc = Nokogiri::HTML(arc.content)
      #    items = doc.content
      #    puts "#{index}: #{items}"
      #    index += 1
      #end
      arc = Archive.find(1)
      doc = Nokogiri::HTML( arc.content )
      items = doc.content
      algor = RMMSeg::Algorithm.new( items )
      loop do 
         tok = algor.next_token
         break if tok.nil?
         puts "#{tok.text} [#{tok.start}..#{tok.end}]"
         end
   end
end

