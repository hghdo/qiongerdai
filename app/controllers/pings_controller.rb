class PingsController < ApplicationController

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
    device=Device.find_by_uid(params[:uid])
    device=Device.new({:installed_at=> Time.parse(params[:from]), :uid => params[:uid], }) if device.blank?
    device.usage_str=params[:usage]
    device.save
    HourPreferUsage.update_usage(params[:hour])    
    respond_to do |format|
      format.any { render :status => :created, :nothing => true  }
      # if @device.save
      #   format.html { redirect_to(@device, :notice => 'Device was successfully created.') }
      #   format.xml  { render :xml => @device, :status => :created, :location => @device }
      # else
      #   format.html { render :action => "new" }
      #   format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      # end
    end
  end
end
