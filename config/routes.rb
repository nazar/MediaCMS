ActionController::Routing::Routes.draw do |map|

  map.connect '', :controller => "TopPage", :action => "index"
  
  map.home '', :controller => 'TopPage', :action => 'index'
  map.home 'home', :controller => 'TopPage', :action => 'enter'
  map.login 'login', :controller => 'account', :action => 'login'
  map.signup 'signup', :controller => 'account', :action => 'signup'

  map.admin   'admin', :controller => 'admin/dashboard', :action => 'index'

  map.forums  'forums', :controller => 'forums', :action => 'index'
  map.forum   'forum/:id', :controller => 'forums', :action => 'show'

  map.topic        'forum/:forum_id/topic/:topic_id',
                    :controller => 'topics', :action => 'show'
  map.prev_topic    'forum/:forum_id/previous/:topic_id',
                    :controller => 'topics', :action => 'previous'
  map.next_topic    'forum/:forum_id/next/:topic_id',
                    :controller => 'topics', :action => 'next'
  map.reply_topic   'forum/:forum_id/reply/:topic_id/post/:post_id',
                    :controller => 'topics', :action => 'reply'
  map.new_topic    'forum/:forum_id/new',
                    :controller => 'topics', :action => 'new'
  map.create_topic 'forum/:forum_id/create',
                    :controller => 'topics', :action => 'create'
                   
              
  map.edit_post    'forum/:forum_id/topic/:topic_id/edit/:post_id',
                   :controller => 'posts', :action => 'edit'
  map.delete_post  'forum/:forum_id/topic/:topic_id/delete/:post_id',
                   :controller => 'posts', :action => 'delete'
  map.reply_post  'forum/:forum_id/topic/:topic_id/reply/:post_id',
                   :controller => 'posts', :action => 'reply'
  map.quote_post  'forum/:forum_id/topic/:topic_id/quote/:post_id',
                   :controller => 'posts', :action => 'quote'
                   
  map.category         'categories/all_photos/:id',   :controller => 'categories', :action => 'all_photos'
  map.category_videos  'categories/videos/:id',       :controller => 'categories', :action => 'videos'
  map.category_audios  'categories/audios/:id',       :controller => 'categories', :action => 'audios'
  map.category_id      'categories/:id',              :controller => 'categories', :action => 'show'
  map.category_name    'categories/:id/:name',        :controller => 'categories', :action => 'show'
  map.category_video   'categories/videos/:id/:name', :controller => 'categories', :action => 'videos'
  map.category_audio   'categories/audios/:id/:name', :controller => 'categories', :action => 'audios'

  map.my_tags  'tags/my/:id/:user', :controller => 'tags', :action => 'my_tags'
  map.tags     'tags/show/:id', :controller => 'tags', :action => 'show'

  map.more_info 'more_information', :controller => 'pages', :action => 'more_information'
  map.pages    'pages/:name', :controller => 'pages', :action => 'view'
  
  # comments 
  map.delete_blog_comment  'comment/:comment_id/blog/:blog_id/delete',   :controller => 'blogs', :action => 'delete_comment'
  map.delete_photo_comment 'comment/:comment_id/photo/:photo_id/delete', :controller => 'photos', :action => 'delete_comment'
  
  map.edit_comment         '/comments/edit/:id',                          :controller => 'comments', :action => 'edit'
  map.delete_comment       '/comments/delete/:id',                        :controller => 'comments', :action => 'delete'
  map.spam_comment         '/comments/spam/:id',                          :controller => 'comments', :action => 'spam'

  #orders
  map.orders_cart           'orders/cart',                               :controller => 'orders', :action => 'cart'  

  #photo
  map.user_about           'account/about/:id',       :controller => 'account', :action => 'about'
  map.user_photos          'photos/by/:id',           :controller => 'photos', :action => 'by'
  map.edit_photo           'photos/edit/:id',         :controller => 'photos', :action => 'edit'
  map.delete_photo         'photos/delete/:id',       :controller => 'photos', :action => 'delete_photo'
  map.preview_photo        'photos/preview/:id',      :controller => 'photos', :action => 'preview'
  map.admin_delete_photo   'photos/admin_delete/:id', :controller => 'photos', :action => 'admin_delete'
  map.photo_more_by_swatch 'photos/same_color/:id',     :controller => 'photos', :action => 'same_color'

  #media
  map.buy_media '/orders/buy/:id', :controller => 'orders', :action => 'buy'
  map.buy_photo '/photos/buy/:id', :controller => 'photos', :action => 'buy'

  #video
  map.videos             'videos/more',             :controller => 'videos', :action => 'more'
  map.video              'videos/view/:id',         :controller => 'videos', :action => 'view'
  map.user_videos        'videos/by/:id',           :controller => 'videos', :action => 'by'
  map.edit_video         'videos/edit/:id',         :controller => 'videos', :action => 'edit'
  map.delete_video       'videos/delete/:id',       :controller => 'videos', :action => 'delete'
  map.admin_delete_video 'videos/admin_delete/:id', :controller => 'videos', :action => 'admin_delete'

  #audio
  map.audios             'audios/more',              :controller => 'audios', :action => 'more'
  map.audio_view         'audios/view/:id/:name',    :controller => 'audios', :action => 'view'
  map.user_audios        'audios/by/:id',            :controller => 'audios', :action => 'by'
  map.audio              'audios/view/:id',          :controller => 'audios', :action => 'view'
  map.edit_audio         'audios/edit/:id',          :controller => 'audios', :action => 'edit'
  map.delete_audio       'audios/delete/:id',        :controller => 'audios', :action => 'delete'
  map.admin_delete_audio 'audios/admin_delete/:id',  :controller => 'audios', :action => 'admin_delete'

  #SEO photos, videos and audio
  map.photo_old_view '/photos/viewphoto/:id/:name', :controller => 'photos', :action => 'viewphoto' 
  map.photo_view '/photos/details/:id/:name', :controller => 'photos', :action => 'details'
  map.video_view '/videos/view/:id/:name',    :controller => 'videos', :action => 'view'
  map.audio_view '/audios/view/:id/:name',    :controller => 'audios', :action => 'view'

  #SEO articles
  map.article_view 'articles/view/:id/:title', :controller => 'articles', :action => 'view'
  
  #SEO links
  map.link_view 'links/view/:id/:name', :controller => 'links', :action => 'view'
  map.link_out  'links/out/:id/:name', :controller => 'links', :action => 'out'
  map.link_view_link 'links/view/:id', :controller => 'links', :action => 'view'
  
  #routes to access commentable objects by ID
  map.photo_view_link      'photos/details/:id',   :controller => 'photos',      :action => 'details'
  map.video_view_link      'videos/view/:id',      :controller => 'videos',      :action => 'view'
  map.audio_view_link      'audios/view/:id',      :controller => 'videos',      :action => 'view'
  map.collection_view_link 'collections/view/:id', :controller => 'collections', :action => 'view'
  map.article_view_link    'articles/view/:id',    :controller => 'articles',    :action => 'view'
  map.blog_view_link       'blogs/show/:id',       :controller => 'blogs'      , :action => 'show'
  map.newsitem_view_link   'news/show/:id',        :controller => 'news'       , :action => 'show'
  map.rssfeeditem_view_link 'news/feed/details/:id',  :controller => 'news', :action => 'view_feed_item' 


  map.collections          'collections/view/:id',     :controller => 'collections', :action => 'view'
  map.collections_my       'collections/my',           :controller => 'collections', :action => 'my'
  map.collections_edit     'collections/edit/:id',     :controller => 'collections', :action => 'edit'
  map.collections_delete   'collections/delete/:id',   :controller => 'collections', :action => 'delete'
  map.collections_members  'collections/members/:id',  :controller => 'collections', :action => 'members'
  map.collections_download 'collections/download/:id', :controller => 'collections', :action => 'download'
  map.collections_new      'collections/new/:id',      :controller => 'collections', :action => 'new'
  map.collection_download  'collections/download/:id', :controller => 'collections', :action => 'download'

  
  #notifications
  map.notifications_disable 'notifications/disable/:event/:type/:token/:id', :controller => 'notifications', :action => 'disable'

  #static pages
  map.static_page      '/pages/view/:id/:name', :controller => 'pages', :action => 'view'

  #license
  map.license_view     'licenses/view/:id',   :controller => 'licenses', :action => 'view'
  map.license_delete   'licenses/delete/:id', :controller => 'licenses', :action => 'delete'
  map.license_edit     'licenses/edit/:id',   :controller => 'licenses', :action => 'edit'
  map.license_my       'licenses/my',         :controller => 'licenses', :action => 'my'

  #clubs
  map.club              'clubs/view/:id',         :controller => 'clubs', :action => 'view' #polymorphic
  map.club_my           'clubs/my',               :controller => 'clubs', :action => 'my'
  map.club_new          'clubs/new',              :controller => 'clubs', :action => 'new'
  map.club_view         'clubs/view/:id',         :controller => 'clubs', :action => 'view'
  map.club_delete       'clubs/delete/:id',       :controller => 'clubs', :action => 'delete'
  map.club_edit         'clubs/edit/:id',         :controller => 'clubs', :action => 'edit'
  map.club_applications 'clubs/applications/:id', :controller => 'clubs', :action => 'view_applications'

  #club news items
  map.club_news_admin  'clubs/news/admin/:club_id', :controller => 'clubs', :action => 'admin_news'
  map.club_news_new    'clubs/news/new/:club_id',   :controller => 'clubs', :action => 'new_news_item'
  map.club_news_edit   'clubs/news/edit/:id',       :controller => 'clubs', :action => 'edit_news_item'

  #club forums
  map.club_forum_admin  'clubs/forums/admin/:club_id', :controller => 'clubs', :action => 'admin_forums'
  map.club_forum_new    'clubs/forums/new/:club_id',   :controller => 'clubs', :action => 'new_club_forum'
  map.club_forum_edit   'clubs/forums/edit/:id',       :controller => 'clubs', :action => 'edit_club_forum'
  map.club_forum_delete 'clubs/forums/delete/:id',     :controller => 'clubs', :action => 'delete_club_forum'


  #new_topic
  map.news_topic        'news/view/:id',            :controller => 'news', :action => 'view'
  map.site_news         'news/site',                :controller => 'news', :action => 'site'
  map.club_news         'news/clubs',               :controller => 'news', :action => 'clubs'
  map.club_news         'news/syndicated',          :controller => 'news', :action => 'syndicated'

  #our rss feeds
  map.feed_site_news       'feeds/site_news',          :controller => 'feed', :action => 'site_news'
  map.feed_club_news       'feeds/clubs_news',         :controller => 'feed', :action => 'clubs_news'
  map.feed_syndicated_all  'feeds/syndicated_all',     :controller => 'feed', :action => 'syndicated_all'


  #rss feeds
  map.rss_feed_item      'news/feed/details/:id',       :controller => 'news', :action => 'view_feed_item'
  map.syndicated_history 'news/syndicated_history/:id', :controller => 'news', :action => 'syndicated_history'


  # Install the default route as the lowest priority.
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

  
end
