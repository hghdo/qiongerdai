class VersionsController < ApplicationController
  
  def ga
    build=33
    respond_to do |format|
      format.any {render :text => build.to_s}
    end
  end
  
  def check_killed
    
  end
end
