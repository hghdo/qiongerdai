class Release < ActiveRecord::Base
  mount_uploader :app_path, ClientAppUploader
end
