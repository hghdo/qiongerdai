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

  # FIXME Verify upload data format before call Model method 
  def create
    # bellow is for ping version 2
    device=Device.find_by_uid(params[:uid])
    device=Device.new({:installed_at=> Time.parse(params[:from]), :uid => params[:uid], :install_date_str=>params[:from][0..7]}) if device.blank?
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
