# Load the rails application
require File.expand_path('../application', __FILE__)


# Initialize the rails application
Qiongerdai::Application.initialize!

Rails.logger=Logger.new("#{Rails.root.to_s}/log/#{Rails.env}.log", "daily")
