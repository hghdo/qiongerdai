class VersionsController < ApplicationController
  
  def last_build_number
    last_build=ClientApp.order('build desc').limit(1)[0]
    respond_to do |format|
      format.any { render :text => last_build.build.to_s }
    end
  end
  
  def down_last_build
    last_build=ClientApp.order('build desc').limit(1)[0]
    Rails.logger.debug { "last url => http://#{request.host}:#{request.port}#{last_build.app.url}" }
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
