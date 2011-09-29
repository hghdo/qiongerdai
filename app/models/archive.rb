require 'zip/zipfilesystem'
require 'devil'

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
  OLD=5
  
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
  
  # generate mobile type html file
  # 
  def write_mobile_html
    File.open(File.join(self.abs_img_dir,"#{self.id}.html"),"w") do |html|
      html.puts('<?xml version="1.0" encoding="UTF-8"?>')
      html.puts('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">')
      html.puts('<html><head>')
      html.puts("<title>#{self.title}</title>")
      html.puts('<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">')
      html.puts('<style type="text/css">')
      html.puts('.autosize{max-width:100%;}')
      html.puts('.fitscreen{max-width:100%;}')
      html.puts('</style>')
      html.puts('</head>')
      html.puts('<body>')
      html.puts("<h2>#{self.title}</h2>")
      html.puts('<div>')
      doc=Nokogiri::HTML(self.content)
      doc.xpath("//img[@class='autosize']").each { |img| img["src"]=img["src"].sub(/\/images\/archives\/\d+\/pics_[hml]\//,'') }
      html.puts(doc.to_html)
      html.puts('</div>')
      html.puts("<p>原文链接: <a href='#{self.url}'>#{self.url.truncate(30)}</a></p>")
      html.puts('</body></html>')
    end
  end

  # FIXME should generate differnet img size package
  def to_zip
    write_mobile_html
    resize_imgs
    pack 'h'
    pack 'm'
    pack 'l'
    FileUtils.chmod 0644, [to_abs(zip_url_path('h')),to_abs(zip_url_path('m')),to_abs(zip_url_path('l'))]
  end
  
  def resize_imgs
    FileUtils.rm_rf to_abs(File.join(root_url_dir,'pics_l'))
    FileUtils.rm_rf to_abs(File.join(root_url_dir,'pics_m'))
    FileUtils.mkdir_p(to_abs(File.join(root_url_dir,'pics_l')))
    FileUtils.mkdir_p(to_abs(File.join(root_url_dir,'pics_m')))
    Dir.foreach(self.abs_img_dir) do |img|
      next if img.start_with?('.')
      # resize img
      if img.end_with? 'html'
        FileUtils.cp(abs_img_path(img,'h'),abs_img_path(img,'m'))
        FileUtils.cp(abs_img_path(img,'h'),abs_img_path(img,'l'))
      else
        di=Devil.with_image(abs_img_path(img,'h')) rescue next
        m_q_img=di.dup.resize(*cal_new_size(di.width,di.height,480))
        m_q_img.save(abs_img_path(img,'m'), :quality => 65 )
        l_q_img=di.dup.resize(*cal_new_size(di.width,di.height,320))
        l_q_img.save(abs_img_path(img,'l'), :quality => 65 )
        # ImageScience.with_image(abs_img_path(img,'h')) do |is_pic|
        #   if is_pic.width>480
        #     new_height=(is_pic.height.to_f/is_pic.width) * 480
        #     is_pic.resize(480,new_height){|np| np.save(abs_img_path(img,'m'))}
        #   else
        #     is_pic.save(abs_img_path(img,'m'))
        #   end
        #   if is_pic.width>320
        #     new_height=(is_pic.height.to_f/is_pic.width) * 320
        #     is_pic.resize(320,new_height){|np| np.save(abs_img_path(img,'l'))}
        #   else
        #     is_pic.save(abs_img_path(img,'l'))
        #   end          
        # end
      end
    end
  end
  
  def pack(quality='h')
    # generate origin quality zip file 
    zip_file=to_abs(zip_url_path(quality))
    FileUtils.rm zip_file, :force => true
    Zip::ZipFile.open(zip_file,Zip::ZipFile::CREATE) do |zip|
      zip.dir.mkdir("#{self.id}")
      Dir.foreach(self.abs_img_dir(quality)) do |img|
        next if img.start_with?('.')
        zip.add("#{self.id}/#{img}",abs_img_path(img,quality))
      end
    end     
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
  
  def cal_new_size(width,height,max_width)
    if width>max_width
      new_height=(height.to_f/width) * max_width
      return max_width,new_height
    else
      return width,height
    end
  end

  def all_image_filenames(quality='h')
    return @images unless @images.blank?
    @images=[]
    Dir.foreach(self.abs_img_dir(quality)) do |file|
      @images<<file unless file.start_with?('.') && file.end_with?('html')
    end
    @images
  end

  def abs_img_path(img_name,quality='h')
    File.join(abs_img_dir(quality),img_name)
  end

  def img_url_path(img_name,quality='h')
    File.join(img_url_dir(quality),img_name)
  end

  # dir part of the image url
  def img_url_dir(quality='h')
    File.join(self.root_url_dir,"pics_#{quality}")
  end

  # absolute path of the dir to save images of an archive
  def abs_img_dir(quality='h')
    aid=File.join(Rails.public_path,img_url_dir(quality))
    FileUtils.mkdir_p(aid) unless File.exists? aid
    aid
  end

  # FIXME has different size of package
  def zip_url_path(quality="h")
    File.join(self.root_url_dir,"#{self.id}_#{quality}.zip")
  end  
  
  def root_url_dir()
    return @srud unless @srud.blank?
    @srud=File.join("/images/archives",self.id.to_s)
    # FileUtils.mkdir_p(@srud) unless File.exists? @srud
    # @srud
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
