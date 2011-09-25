require 'zip/zipfilesystem'
require 'crawl/down_img'

namespace :archives do
  desc "clean old archive images"
  task :clean => :environment  do
    Archive.where(["status=?",Archive::DELETED]).each do |arc|
      archive_img_path=File.join(Rails.public_path,arc.root_url_dir)
      FileUtils.rm_rf(archive_img_path )
    end
    oks=Archive.where(["status=?",Archive::OK]).count
    next if oks<50
    Archive.where(["status=?",Archive::OK]).limit(oks-50).order("updated_at").each do |arc|
      # arc.update_attribute("status", Archive::OLD )
      archive_img_path=File.join(Rails.public,arc.root_url_dir)
      FileUtils.rm_rf(archive_img_path, :force => true )
    end
  end
  
  desc "change not verified archives that was downloaded before 2 days to deleted status "
  task :status2del => :environment do
    Archive.where(["status=? and created_at<?",Archive::ANALYZED,(Time.now-1.day)]).each do |arc|
      arc.update_attribute("status",Archive::DELETED)
    end
  end
end

