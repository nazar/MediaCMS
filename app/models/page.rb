class Page < ActiveRecord::Base

  #content type
  # 0 - Red Cloth
  # 1 - HTML

  EXCERPT_LENGTH = 25
  
  validates_presence_of   :name
  validates_uniqueness_of :name, :case_sensitive => false
#  acts_as_list :scope => :parent

  named_scope :visible, :conditions => ['visible = ?', true]

  #class methods

  def self.content_types
    {'Red Cloth' => 0, 'HMTL' => 1}
  end

  def self.pages
    self.visible.find(:all, :order => 'name ASC')
  end
  
  #construct array of all built-in pages
  def self.system_pages
    pages = {'photos' =>
      [ ['Upload Photo', '/photos/upload'],
        ['Google Map Photos', '/maps/photos'],
        ['Photo Tags', '/tags/photos'],
        ['My Photos', '/photos/mypictures'],
        ['My Library', '/photos/library'],
        ['My Favourites', '/photos/favourites'],
        ['More Photos', '/photos/more_photos'],
        ['Top Photos', '/photos/more_photos']
      ],
    'clubs' =>
      [ ['Create Club', '/clubs/my'],
        ['View Clubs', '/clubs']
      ],
    'collections' =>
      [ ['Create Collection', '/collections/new'],
        ['View Collection', '/collections'],
        ['My Collection', '/collections/my']
      ],
    'user_configuration' =>
      [ ['My Details', '/account'],
        ['My Licenses', '/licenses/my'],
        ['My Accounting Page', '/orders/credit'],
        ['My Hosting Plan', '/account/account'],
        ['My Notifications', '/notifications/my_notifications']
      ],
    'access' =>
      [ ['Login', '/account/login'],
        ['Logout', '/account/logout'],
        ['Register', '/account/register'],
        ['Administration', '/admin/dashboard']
      ],
    'news' =>
      [ ['News', '/news'],
        ['Site News', '/news/site'],
        ['Club News', '/news/clubs'],
        ['Syndicated News', '/news/syndicated']
      ],
    'home' =>
      [ ['Home page', '/home'],
        ['New Photos', '/#recent_photo_link'],
        ['New Collections', '/#recent_collection_link'],
        ['New Links', '/#recent_links_link'],
        ['New Blogs', '/#recent_blogs_link'],
        ['New Topics', '/#recent_topics_link'],
        ['New Comments', '/#recent_comments_link'],
      ]
    }
    #optional photo links modules
    pages.merge!({'photography_links' =>
      [ ['Popular Links', '/links'],
        ['Today Links', '/links/today'],
        ['Week Links', '/links/week'],
        ['Month Links', '/links/month'],
        ['My Submitted Links', '/links/my_links'],
        ['Favourite Links', '/links/my_favouritess'],
        ['Submit Link', '/links/add_link']
      ]}) if Configuration.module_links
    #optional forums module
    pages.merge!({'forums' =>
      [ ['Forums' , '/forums']
      ]}) if Configuration.module_forums
    #optional blogs module
    pages.merge!({'blogs' =>
      [ ['Latest Blogs', '/blogs'],
        ['Create Blog', '/blogs/my_blog']
      ]}) if Configuration.module_blogs
    #optional video module
    pages.merge!({'videos' =>
      [
       ['Videos Index', '/videos'],
       ['Upload Video', '/videos/upload'],
       ['Videos on Google Maps', '/maps/videos'],
       ['Videos Tags', '/tags/videos'],
       ['My Videos', '/videos/my'],
       ['My Library', '/videos/library'],
       ['My Favourites', '/videos/favourites'],
       ['More Videos', '/videos/more'],
       ['Top Videos', '/videos/top']
      ]}) if Configuration.module_videos
    #optional audio module
    pages.merge!({'audio' =>
      [
       ['Audio Index', '/audios'],
       ['Upload Audio File', '/audios/upload'],
       ['Audio on Google Maps', '/maps/audios'],
       ['Audio Tags', '/tags/audios'],
       ['My Audio Files', '/audios/my'],
       ['My Library', '/audios/library'],
       ['My Favourites', '/audios/favourites'],
       ['More Audio', '/audios/more'],
       ['Top Audios', '/audios/top']
      ]}) if Configuration.module_audios
    #
    pages
  end

  #instance methods

  def link_name
    name.to_permalink
  end
  
  def viewed_page
    self.viewed += 1
  end

  def formatted_content
    case content_type
      when 0; Misc.format_red_cloth(content)
      when 1; content
    end
  end
  
  def excerpt
    result = ''
    if content && content.length > 0
      result = content.length > EXCERPT_LENGTH ? content[0..EXCERPT_LENGTH] << ' ...' : content
    end
    result
  end

  def content_type_desc
    Page.content_types.index(content_type)
  end

  def created_by_name
    User.find_by_id(updated_by).pretty_name
  end
  
end
