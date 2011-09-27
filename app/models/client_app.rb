class ClientApp < ActiveRecord::Base
  attr_accessible :app, :platform
  mount_uploader :app, ClientAppUploader
  
end
