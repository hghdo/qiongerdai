require 'zip/zipfilesystem'

class Archive < ActiveRecord::Base
  belongs_to :provider

  validates_uniqueness_of :url, :message => "DUPLICATED"
  validates_uniqueness_of :uid, :message => "DUPLICATED"

  TINY_THUMB='thumb48.jpg'
  SMALL_THUMB='thumb96.jpg'
  BIG_THUMB='thumb150.jpg'
  # Archive status
  # new => analyzed => synced => locked(being verified by some admin) <=> ok(published) => deleted(ignored)
  DELETED=-2
  IGNORE=-1
  NEW=0
  ANALYZED=1
  SYNCED=2
  LOCKED=3
  OK=4
  



  def content_dom
    return @dom if not @dom.blank?
    @dom=Nokogiri::HTML(self.content)
  end

  # Remove fixed width of table elements
  def adjust_table_width
    content_dom.xpath('//table').each do |ele|
      ele['width']=''
    end
    self.update_attribute('content',content_dom.to_html)
  end

  # FIXME should generate differnet img size package
  def to_zip
    # generate mobile type html file
    File.open(File.join(self.abs_img_dir,"#{self.id}.html"),"w") do |html|
      html.puts('<?xml version="1.0" encoding="UTF-8"?>')
      html.puts('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">')
      html.puts('<html><head>')
      html.puts('<title></title>')
      html.puts('<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">')
      html.puts('<style type="text/css">.autosize{max-width:100%;}</style>')
      html.puts('</head>')
      html.puts('<body>')
      html.puts('<div>')
      doc=Nokogiri::HTML(self.content)
      doc.xpath("//img[@class='autosize']").each { |img| img["src"]=img["src"].sub(/\/images\/archives\/\d+\//,'') }
      html.puts(doc.to_html)
      html.puts('</div>')
      html.puts('</body></html>')
    end
    # generate origin quality zip file 
    zip_file=to_abs(zip_url_path('h'))
    FileUtils.rm zip_file, :force => true
    Zip::ZipFile.open(zip_file,Zip::ZipFile::CREATE) do |zip|
      zip.dir.mkdir("#{self.id}")
      Dir.foreach(self.abs_img_dir) do |img|
        zip.add("#{self.id}/#{img}","#{self.abs_img_dir}/#{img}") unless img=~/^\./ 
      end
    end
    
    # generated middle quality zip file
    clear_tmp
    zip_file=to_abs(zip_url_path('m'))
    FileUtils.rm zip_file, :force => true
    Zip::ZipFile.open(zip_file,Zip::ZipFile::CREATE) do |zip|
      zip.dir.mkdir("#{self.id}")
      Dir.foreach(self.abs_img_dir) do |img|
        next if img.start_with?('.')
        # resize img
        if img.end_with? 'html'
          zip.add("#{self.id}/#{img}","#{self.abs_img_dir}/#{img}")
        else
          ImageScience.with_image("#{self.abs_img_dir}/#{img}") do |is_pic|
            if is_pic.width>480
              new_height=(is_pic.height.to_f/is_pic.width) * 480
              is_pic.resize(480,new_height){|np| np.save("#{tmp_path}/#{img}")}
            else
              is_pic.save("#{tmp_path}/#{img}")
            end
          end
          # add to zip file   
          zip.add("#{self.id}/#{img}","#{tmp_path}/#{img}")
        end
      end
    end
    
    # generated low quality zip file
    clear_tmp
    zip_file=to_abs(zip_url_path('l'))
    FileUtils.rm zip_file, :force => true
    Zip::ZipFile.open(zip_file,Zip::ZipFile::CREATE) do |zip|
      zip.dir.mkdir("#{self.id}")
      Dir.foreach(self.abs_img_dir) do |img|
        next if img.start_with?('.')
        # resize img
        if img.end_with? 'html'
          zip.add("#{self.id}/#{img}","#{self.abs_img_dir}/#{img}")
        else
          ImageScience.with_image("#{self.abs_img_dir}/#{img}") do |is_pic|
            if is_pic.width>320
              new_height=(is_pic.height.to_f/is_pic.width) * 320
              is_pic.resize(320,new_height){|np| np.save("#{tmp_path}/#{img}")}
            else
              is_pic.save("#{tmp_path}/#{img}")
            end
          end
          # add to zip file   
          zip.add("#{self.id}/#{img}","#{tmp_path}/#{img}")
        end
      end
    end
    FileUtils.rm_rf tmp_folder
  end
  
  def package(quality='m')
    
  end
  
  def clear_tmp
    FileUtils.rm_rf tmp_folder
    FileUtils.mkdir_p tmp_folder
  end
  
  def tmp_folder
    @tmp||=File.join(Rails.root,"tmp/archive_#{self.id}")
  end

  # deprecated
  # Used for update img['src'] attributes after archive id has changed
  # def refresh_img_url(old_id)
  #   return true if self.id==old_id.to_i
  #   ns=content_dom
  #   ns.xpath('//img').each do |pi|
  #     pi['src']=pi['src'].sub(/\/images\/archives\/\d+\//,"/images/archives/#{self.id}/") if pi['class']=='autosize' && pi['src']=~/\/images\/archives\/\d+\//
  #     logger.debug("AAAA => #{pi['src']}")
  #   end
  #   self.thumbnail=self.thumbnail.sub(/\/images\/archives\/\d+\//,"/images/archives/#{self.id}/")
  #   self.content=ns.to_html 
  #   self.save
  # end

  # deprecated this method has been already moved to crawl library.
  def crawl_imgs()
    puts "crawl images of #{self.title}"
    thumbnail_url=nil
    content_node_set=Nokogiri::HTML(self.content)
    page_url=URI(self.url)
    thumbnail_url=nil
    imgs=content_node_set.xpath('.//img')
    threads=[]
    imgs.each do |pi|
      # skip noisy images
      #next if html_struct[:noisy_img_patterns].any? {|patt| pi['src']=~ patt}
      threads<<Thread.new do
        begin
          #puts pi['src']
          url=(page_url.merge(pi['src']))
          Thread.exit if File.extname(url.path).downcase==".gif"
          flattened_name=url.path.sub(/\//,'').gsub(/\//,'_') 
          save_to=abs_img_path(flattened_name)
          puts "Image file does not exist, crawl it."
          http=Net::HTTP.new(url.host,url.port)
          http.read_timeout=10
          http.open_timeout=10
          req=Net::HTTP::Get.new(url.path)
          req.add_field 'HTTP_REFERER', self.url
          res=http.request(req)
          Thread.exit if res.class!=Net::HTTPOK
          open(save_to, 'wb' ) { |file|
            file.write(res.body)
          }
          # unless File.exists? iwp 
          # end
          #FileUtils.cp(iwp,abs_img_path(flattened_name))
          img_url_in_archive=File.join(img_url_dir,flattened_name)
          pi['src']=img_url_in_archive
          pi['class']='autosize'
          # remove image hardcode size attribute. 
          %w{width height style onmouseover onclick}.each{|att| pi.remove_attribute att}
          # FIXME Should create small size image as well. 
          ImageScience.with_image(save_to){|thisimg| thumbnail_url=img_url_in_archive if thisimg.width>150} if thumbnail_url.blank?
        rescue Exception => e
          puts "Error occurred when crawl images => #{e}"
          puts "Image url => #{url.to_s}"
          puts e.backtrace
          Thread.exit
        end
      end
    end
    threads.each {|thr| thr.value}
    self.update_attributes({:content => content_node_set.to_html,:thumbnail => thumbnail_url,:status => ANALYZED})
  end
  

  def all_image_filenames
    return @images unless @images.blank?
    @images=[]
    Dir.foreach(self.abs_img_dir) do |file|
      @images<<file unless file.start_with?('.') && file.end_with?('html')
    end
    @images
  end

  def abs_img_path(img_name)
    File.join(abs_img_dir,img_name)
  end

  def img_url_path(img_name)
    File.join(img_url_dir,img_name)
  end

  # dir part of the image url
  def img_url_dir
    return @ird unless @ird.blank?
    @ird=File.join(self.root_url_dir,"pics")
  end

  # absolute path of the dir to save images of an archive
  def abs_img_dir
    return @aid unless @aid.blank?
    @aid=File.join(Rails.public_path,img_url_dir)
    FileUtils.mkdir_p(@aid) unless File.exists? @aid
    @aid
  end

  # FIXME has different size of package
  def zip_url_path(size="m")
    File.join(self.root_url_dir,"#{self.id}_#{size}.zip")
  end  
  
  def root_url_dir()
    return @srud unless @srud.blank?
    @srud=File.join("/images/archives",self.id.to_s)
    FileUtils.mkdir_p(@srud) unless File.exists? @srud
    @srud
  end
  
  def to_abs(path)
    File.join(Rails.public_path,path)
  end

  def thumb_filenames()
    return BIG_THUMB,SMALL_THUMB,TINY_THUMB #"thumb150","thumb96","thumb48"
  end

  def small_thumb_url_path
    img_url_path(SMALL_THUMB)
  end
  def tiny_thumb_url_path
    img_url_path(TINY_THUMB)
  end
  def big_thumb_url_path
    img_url_path(BIG_THUMB)
  end

  def locked?
    self.status==LOCKED
  end

  def ok?
    self.status==OK
  end

  def analyzed?
    self.status==ANALYZED    
  end

  def synced?
    self.status==SYNCED
  end

end
