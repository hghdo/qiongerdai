class PingsController < ApplicationController
  
  protect_from_forgery :except => :create
  
  # GET /devices/1
  # GET /devices/1.xml
  def show
    @device = Device.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device }
    end
  end
  
  def activate
    device=Device.find_by_uid(params[:uid])
    if device.blank?
      device=Device.new({
        :installed_at=> Time.parse(params[:installed_at]), 
        :uid => params[:uid], 
        :install_date_str=>params[:installed_at][0..7], 
        :version => params[:build], })
      device.save
    end
    respond_to do |format|
      format.any { render :status => :created, :nothing => true  }
    end
  end

  # FIXME Verify upload data format before call Model method 
  def create
    # bellow is for ping version 2
    device=Device.find_by_uid(params[:uid])
    if device.blank?
      device=Device.new({:uid => params[:uid]})
      installed_date=params[:installed_at]||params[:from]
      device.installed_at=Time.parse(params[:installed_at]||params[:from])
      device.install_date_str=installed_date[0..7]
    end
    device.usage_str=params[:usage]
    device.debug=params[:app][:debug]
    device.version=params[:app][:version_code]
    device.os=params[:dev][:os][:name]
    device.os_version=params[:dev][:os][:sdk]
    device.device_name=params[:dev][:model]
    device.save
    HourPreferUsage.update_usage(params[:hour])    
    
    # if new ping version used add new code here
    # 
    respond_to do |format|
      format.any { render :status => :created, :nothing => true  }
    end
  end
end
