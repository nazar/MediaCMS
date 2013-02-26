module FeedHelper

  def render_photo_feed(photos, xml, options)
    xml.rss "version" => "2.0",
      "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
      "xmlns:georss" => "http://www.georss.org/georss",
      "xmlns:media" => "http://search.yahoo.com/mrss/",
      "xmlns:atom" => "http://www.w3.org/2005/Atom",
      "xmlns:geo" => "http://www.w3.org/2003/01/geo/wgs84_pos#" do
      xml.channel do
        xml.title options[:title]
        xml.link url_for(:only_path => false,
          :controller => 'top_page')
        if photos && photos.length > 0
          xml.pubDate CGI.rfc1123_date(photos.first.created_on)
          xml.description h(options[:description])
          photos.each do |photo|
            xml.item do
              xml.title photo.title
              xml.link url_for(:only_path => false,
                :controller => 'photos', :action => 'details', :id => photo.id)
              xml.description do
                xml. << clean_escape(h(rss_photo_block(photo)))
              end
              Photo.find_markers_for(photo).each do |marker|
                xml.georss :point, "#{marker.lat.to_s} #{marker.long.to_s}"
              end
              xml.pubDate CGI.rfc1123_date(photo.created_on)
              xml.guid url_for(:only_path => false,
                :controller => 'photos', :action => 'details', :id => photo.id)
              xml.author h(photo.user.pretty_name)
              xml.media :thumbnail , :url => thumbnail_path(photo,{:only_path => false})
              xml.media :content , :url => thumbnail_path(photo,{:only_path => false})
            end
          end
          if options[:page] #pagination support
            if photos.respond_to?('page_count') #we have a pagination object
              if options[:page].to_i < (photos.page_count - 1)
                xml.atom :link, :rel => 'next', :href => url_for(options[:url].merge({:page => options[:page].to_i+1}))
              end
            end
          end
        end
      end
    end
  end

  def render_item_feed(objects, xml, options)
    xml.rss "version" => "2.0",
      "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
      xml.channel do
        xml.title options[:title]
        xml.link url_for(:only_path => false,
          :controller => 'top_page')
        xml.pubDate CGI.rfc1123_date(objects.first.created_at)
        xml.description h(options[:description])
        objects.each do |obj|
          xml.item do
            xml.title obj.title
            xml.link url_for(:only_path => false,
              :controller => obj.class.to_s.downcase.pluralize,
              :action => 'view',
              :id => obj.id,
              :name => obj.perma_title)
            xml.description do
              xml. << clean_escape(h(obj.description))
            end
            xml.pubDate CGI.rfc1123_date(obj.created_at) if obj.created_at
            xml.author h(obj.user.pretty_name) if obj.user
          end
        end
      end
    end
  end

  def clean_escape(text)
    text.gsub('"','&quot;')
  end

  def feed_title_block(title, feed_link_options, options = {})
    options[:pic_lens] ||= true unless options[:pic_lens] === false
    options[:rss_icon] ||= true unless options[:rss_icon] === false
    add_extra_header_content( auto_discovery_link_tag(:rss, feed_link_options, {:title => title} ) )  if options[:auto_rss] 
    markaby do
      div.block_title do
        div.class_title do
          div.feed { link_to(image_tag('rss.gif'), feed_link_options, {:class => 'no_underline'}) } if options[:rss_icon]
          h2 { title }
          if Configuration.pic_lens_support && options[:pic_lens]
            link_to '&nbsp;&nbsp;&nbsp;' << image_tag("http://lite.piclens.com/images/PicLensButton.png", :align => 'absmiddle' ) ,
              "javascript:PicLensLite.start();"
          end
        end
      end
    end
  end

  def feed_title_link_block(title, title_link, feed_link_options, options = {})
    options[:title_link] ||= true unless options[:title_link] === false
    add_extra_header_content( auto_discovery_link_tag(:rss, feed_link_options, {:title => title} ) )  if options[:auto_rss]
    markaby do
      div.block_title do
        div.class_title do
          div.feed { link_to(image_tag('rss.gif'), feed_link_options, {:class => 'no_underline'}) }
          h2 { title }
          span.link {title_link} if options[:title_link]
        end
      end
    end
  end


end
