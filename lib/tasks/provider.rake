require 'anemone'
require 'open-uri'
require 'simple-rss'
require 'net/http'
require 'anemone_helper'

namespace :provider do
  desc "Fetch articles from enabled providers"
  task :fetch => :environment do
    puts "#{Time.now} Now run provider:fetch command!"
    Provider.all.each do |provider|
      next unless provider.enabled?
      # Frenqunce of fetch content from provider.
      next if !provider.fetched_at.blank? && provider.fetched_at+2.hour>Time.now
      puts "Going to fetch provider => #{provider.title}"
      Rails.logger.info "Going to fetch provider => #{provider.title}"
      case provider.format.downcase
      when 'html'
        AnemoneHelper.new(provider).start_crawl
      when 'rss'
        site=provider.url
        rss = SimpleRSS.parse open(site)
        rss.items.each do |item|
          next if item.link.blank? || Archive.exists?(:url => item.link)
          Rails.logger.info "New RSS item =>#{item.title}"
          Arc=Archive.create({
              :title => item.title,
              :url => item.link,
              :desc => item.description,
              :provider_id => provider.id,
              :cat => provider.category.alias,
              :content => item.content_encoded,
              :pub_date => item.pubDate,
          })
        end
#        doc=Nokogiri::XML(open(site))
#        items=doc.xpath('//item')
#        items.each do |item|
#          title=item.xpath('./title')[0].content
#          link=item.xpath('./link')[0].content
#          next if (link.blank? || Archive.exists?(:url => link))
#          desc_cdata=item.xpath('./description')[0].child rescue next
#          content_cdata=item.xpath('./content:encoded')[0].child rescue next
#          puts "find a new RSS item =>#{title}"
#          Arc=Archive.create({
#              :title => title,:url => link,
#              :desc => desc_cdata.to_html(:encoding => 'utf-8'),
#              :def_category => provider.category,
#              :content => content_cdata.to_html(:encoding => 'utf-8'),
#          })
#        end
      when 'atom'
      end
      provider.update_attribute('fetched_at', Time.now)
    end
  end

  desc "Backup provider informations to provider.xml file"
  task :backup => :environment do
    xml=Provider.all.to_xml() { |i|  }
    #provider_xml=File.join(Rails::configuration.root_path, '/provider.xml')
    provider_xml=File.expand_path('../provider.xml', __FILE__)
    File.open(provider_xml,"w"){|f| f.puts xml}
  end

  desc "Restore provider informations from provider.xml file"
  task :restore => :environment do
    Provider.delete_all
    provider_xml=File.expand_path('../provider.xml', __FILE__)
    f=File.open(provider_xml,"r")
    hash=Hash.from_xml(f)
    f.close
    hash['providers'].each do |ph|
      provider=Provider.new(ph)
      provider.id=ph['id']
      provider.save
    end
    #hash['providers'].each {|ph| Provider.create(ph)}
  end

end
