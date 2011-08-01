xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do

   xml.title       "zadui.cn|扎堆"
   xml.link        url_for archives_url 
   xml.description "爱美之心人人都有"
   xml.pubDate     Time.now.rfc822

   @archives.each do |archive|
     xml.item do
       xml.title       archive.title
       xml.link        url_for archive_url(archive)
       xml.description archive.desc
       xml.thumbUrl url_for("http://#{request.host}:#{request.port}#{archive.small_thumb_url_path}")
       xml.zipPkgUrl url_for("http://#{request.host}:#{request.port}#{archive.zip_url_path}")
       xml.guid archive.id
       xml.pubDate archive.pub_date.rfc822
       #xml.big_thumbnail url_for("http://#{request.host}/#{archive.tiny_thumb_url_path}")
       #xml.small_thumbnail url_for("http://#{request.host}/#{archive.tiny_thumb_url_path}")
       #xml.guid        url_for archive_url(archive)
     end
   end

 end
end
