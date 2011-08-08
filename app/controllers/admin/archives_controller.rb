class Admin::ArchivesController < Admin::ConsoleController

  before_filter :authorized?, :except => :create
  before_filter :load_archive, :except => [:index,:create,:new,:allocate]
  # GET /archives
  # GET /archives.xml
  def index
    @title="文章列表"
    status=params[:status].blank? ? Archive::SYNCED : (params[:status].to_i rescue Archive::SYNCED)
    puts "AAAAAAAAAAAAAA=> #{status}"
    @archives = Archive.where(["status=?",status]).order("created_at desc").page(params[:page]).per(15)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @archives }
    end
  end

  def ok
    @archive.to_zip
    @archive.update_attribute('status',Archive::OK)
    expire_page feed_archives_path 
    respond_to do |wants|
      wants.html { redirect_to admin_archives_path(:status => 1)}
    end
    
  end

  def thumb
    @images=@archive.all_image_filenames
    @source=params[:source]||@archive.thumbnail
    @source=@archive.img_url_path(@source) if @source[0]!=47 #'/' is 47
    render :layout => false
  end

  def crop
    thumb_source=File.basename(params[:source])
    big,small,tiny=@archive.thumb_filenames()
    ImageScience.with_image(@archive.abs_img_path(thumb_source)) do |pic|
      left=params[:x1].to_i
      top=params[:y1].to_i
      right=params[:x1].to_i+params[:width].to_i
      bottom=params[:y1].to_i+params[:height].to_i
      pic.with_crop(left,top,right,bottom) do |pic|
        pic.resize(150,150) {|np| np.save(@archive.abs_img_path(big))}
        pic.resize(96,96) {|sp| sp.save(@archive.abs_img_path(small))}
        pic.resize(48,48) {|tp| tp.save(@archive.abs_img_path(tiny))}
      end
    end
    @archive.update_attribute('thumbnail',@archive.img_url_path(big))
     respond_to do |wants|
       wants.html{ redirect_to admin_archive_path(@archive) }
     end
     
  end

  # GET /admin/archives/1
  # GET /admin/archives/1.xml
  def show
    @title="编辑文章"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @archive }
    end
  end

  # GET /archives/new
  # GET /archives/new.xml
  def new
    @archive = Archive.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @archive }
    end
  end

  # GET /archives/1/edit
  def edit
    @archive = Archive.find(params[:id])
  end

  # POST /archives
  # POST /archives.xml
  # This method is only used for sychronize archives bettween crawl and web servers.
  # FIXME IP address and password check should be added to forbidden illegal request
  # FIXME if there is a same url archive existed then ignore the uploaded one.
  def create
    ok=false
    begin
      @archive = Archive.new(params[:archive])
      @archive.id=params[:archive][:id]
      @archive.save!
      #@archive.id=params[:archive][:id] # Since id can't be set mass-assigned.
      upload_io=params[:archive_imgs]
      # Save zip file to local 
      zip_file= File.join(@archive.abs_img_dir,"#{@archive.id}.zip")#upload_io.original_filename)
      File.open(zip_file,'w') { |f| f.write(upload_io.read)}
      system("unzip #{zip_file} -d #{@archive.abs_img_dir}")
      @archive.refresh_img_url(params[:archive][:id])
      #FileUtils.rm zip_file, :force => true
      ok=true
    rescue ActiveRecord::RecordInvalid => e
      # Resumed that only duplicated url can cause active record validation failed.
      # So ignore this error and return HTTP 201 to upload client.
      logger.error("#{e.class} => #{e.message}")
      @archive.errors.each { |err| logger.error(err) }
      ok=true
    rescue Exception => e 
      ok=false
    end

    respond_to do |format|
      if ok #@archive.save
        format.html { redirect_to([:admin,@archive], :notice => 'Archive was successfully created.') }
        format.xml  { render :xml => @archive, :status => :created, :location => @archive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /archives/1
  # PUT /archives/1.xml
  def update

    respond_to do |format|
      if @archive.update_attributes(params[:archive])
        format.html { redirect_to([:admin,@archive], :notice => 'Archive was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /archives/1
  # DELETE /archives/1.xml
  def destroy
    @archive.update_attribute('status',Archive::DELETED)

    respond_to do |format|
      format.html { redirect_to(admin_archives_path :status => 1 ) }
      format.xml  { head :ok }
    end
  end

  def allocate
    archive=Archive.where("status=?",Archive::SYNCED).order('created_at desc').first  
    archive.update_attribute('status',Archive::LOCKED)
    redirect_to admin_archive_path(archive)
  end

  def unlock
    @archive.update_attribute('status',Archive::SYNCED)
    redirect_to admin_console_path
  end

  def load_archive
    @archive=Archive.find(params[:id])
  end
end
