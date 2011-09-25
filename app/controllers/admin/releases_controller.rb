class Admin::ReleasesController < ApplicationController
  # GET /admin/releases
  # GET /admin/releases.xml
  def index
    @admin_releases = Admin::Release.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_releases }
    end
  end

  # GET /admin/releases/1
  # GET /admin/releases/1.xml
  def show
    @admin_release = Admin::Release.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_release }
    end
  end

  # GET /admin/releases/new
  # GET /admin/releases/new.xml
  def new
    @admin_release = Admin::Release.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_release }
    end
  end

  # GET /admin/releases/1/edit
  def edit
    @admin_release = Admin::Release.find(params[:id])
  end

  # POST /admin/releases
  # POST /admin/releases.xml
  def create
    @admin_release = Admin::Release.new(params[:admin_release])

    respond_to do |format|
      if @admin_release.save
        format.html { redirect_to(@admin_release, :notice => 'Release was successfully created.') }
        format.xml  { render :xml => @admin_release, :status => :created, :location => @admin_release }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_release.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/releases/1
  # PUT /admin/releases/1.xml
  def update
    @admin_release = Admin::Release.find(params[:id])

    respond_to do |format|
      if @admin_release.update_attributes(params[:admin_release])
        format.html { redirect_to(@admin_release, :notice => 'Release was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin_release.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/releases/1
  # DELETE /admin/releases/1.xml
  def destroy
    @admin_release = Admin::Release.find(params[:id])
    @admin_release.destroy

    respond_to do |format|
      format.html { redirect_to(admin_releases_url) }
      format.xml  { head :ok }
    end
  end
end
