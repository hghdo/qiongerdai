require 'rest_client'
require 'zip/zipfilesystem'
require 'crawl/down_img'

namespace :archives do
  desc "analyze archive, including save images to local and select one as thumbnail"
  task :analyze => :environment do
    Crawl::DownImg.new.crawl
    #Archive.where(["analyzed=?",false]).first.crawl_imgs
    #Archive.where(["status=?",Archive::NEW]).each do |arc|
    #  arc.adjust_table_width
    #  arc.crawl_imgs
    #end
  end

  desc "upload analyzed file to web server along with a zip file including all related images"
  task :upload => :environment do
    web_server="http://ec2-46-51-247-113.ap-northeast-1.compute.amazonaws.com/admin/archives"
    #web_server="http://www.zadui.cn/admin/archives"
    #server_url=URI(web_server)
    #http=Net::HTTP.new(server_url.host,server_url.port)
    #http.start
    
    Archive.where(["status=?",Archive::ANALYZED]).each do |arc|
      zip_file=File.join("/tmp","#{arc.id.to_s}.zip")
      FileUtils.rm zip_file, :force => true
      Zip::ZipFile.open(zip_file,Zip::ZipFile::CREATE) do |zip|
        Dir.foreach(arc.abs_img_dir) do |img|
          zip.add("#{img}","#{arc.abs_img_dir}/#{img}") unless img=~/^\./ 
        end
      end
      begin
        res=RestClient.post(web_server,:archive => arc.attributes,:archive_imgs => File.new(zip_file))
      rescue Exception => e
        puts e.message
        raise
      end
      if res.code==201
        arc.update_attribute('status',Archive::SYNCED)
      end
      FileUtils.rm zip_file, :force => true
      sleep 3
      #break;
    end
  end
end

