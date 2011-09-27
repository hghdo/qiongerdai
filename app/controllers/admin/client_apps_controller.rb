require 'fileutils'

class Admin::ClientAppsController < Admin::ConsoleController
  # GET /admin/releases
  # GET /admin/releases.xml
  def index
    @apps = ClientApp.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @apps }
    end
  end

  # GET /admin/releases/1
  # GET /admin/releases/1.xml
  def show
    @app = ClientApp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @app }
    end
  end

  # GET /admin/releases/new
  # GET /admin/releases/new.xml
  def new
    @client_app = ClientApp.new({:platform => 'android-phone'})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app }
    end
  end

  # GET /admin/releases/1/edit
  def edit
    @app = ClientApp.find(params[:id])
  end

  # POST /admin/releases
  # POST /admin/releases.xml
  def create
    @client_app = ClientApp.new(params[:client_app])
    Rails.logger.debug { "app_path here is  => #{@client_app.app.current_path}" }
    aapt=File.join(Rails.root,"android-platform-tools/aapt")
    cmd="#{aapt} d badging #{@client_app.app.current_path}"
    apk_info=IO.popen(cmd) { |f| f.readline }
    Rails.logger.debug { "apk-info is => #{apk_info}" }
    arr=apk_info.scan(/name='(.+)'\sversionCode='(.+)'\sversionName='(.+)'/)
    @client_app.pkg_name,@client_app.build,@client_app.version_name=*arr[0]
    # new_abs_path=File.join(Rails.root,@client_app.app_path.store_dir,"#{app_file_name}-#{@client_app.build}.#{app_ext_name}")
    # FileUtils.mv(@client_app.app_path.current_path,new_abs_path)
    # @client_app.app_path=File.open(new_abs_path)
    # Rails.logger.debug { "AAAAA  => #{new_abs_path}" }
    respond_to do |format|
      if @client_app.save
        format.html { redirect_to(admin_client_apps_path, :notice => 'ClientApp was successfully created.') }
        format.xml  { render :xml => @client_app, :status => :created, :location => @client_app }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @client_app.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/releases/1
  # PUT /admin/releases/1.xml
  def update
    @app = ClientApp.find(params[:id])

    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to(@app, :notice => 'ClientApp was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/releases/1
  # DELETE /admin/releases/1.xml
  def destroy
    @app = ClientApp.find(params[:id])
    @app.destroy

    respond_to do |format|
      format.html { redirect_to(apps_url) }
      format.xml  { head :ok }
    end
  end
end
