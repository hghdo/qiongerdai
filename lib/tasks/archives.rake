require 'zip/zipfilesystem'
require 'crawl/down_img'

namespace :archives do
  desc "clean old archive images"
  task :clean => :environment,  do
      Archive.where(["status=?",Archive::DELETED]).each do |arc|
        archive_img_path=File.join(Rails.public,arc.root_url_dir)
        FileUtils.rm_rf(archive_img_path, :force => true )
      end
  end
end

