class VersionsController < ApplicationController
  
  def last_build_number
    build=58
    respond_to do |format|
      format.any { render :text => build.to_s }
    end
  end
  
  def down_last_build
    # try find the last build under public/releases/
    # File.join(Rails.public_path,"releases")
    respond_to do |format|
      format.any do
        render :status => 302, :location => "http://#{request.host}:#{request.port}/dl/zaduiReader.apk", :nothing => true
      end
    end
    # redirect_to(url_for("http://#{request.host}:#{request.port}/releases/zaduiReader.apk"))

  end
  
  # def check_killed
  #   
  # end
end
