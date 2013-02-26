namespace :photos do

  desc 'Create default host plans'
  task :create_default_host_plans => :environment do
    #create host plans
    unless HostPlan.find_by_name('Free')
      default = HostPlan.create(:name => 'Free', :description => 'A free account is required to gain interactive access. Once signed up you will be able to post to our forums and post comments on both our blogs and photos. Although a limited space is provided to upload your own photos, these cannot be sold and will be freely available to all our members.',
                      :disk_space => 20, :monthly_fee => 0, :default_plan => 1)
    end
    unless HostPlan.find_by_name('Professional')
      HostPlan.create(:name => 'Professional', :description => 'Professional hosting plan allows photographers to store upto 100 MB of images online and offer these for sale.',
                      :disk_space => 100, :monthly_fee => 4.99, :commerce => 1, :blog => 1, :club => 1)
    end
    unless HostPlan.find_by_name('Premium')
      HostPlan.create(:name => 'Premium', :description => 'Our Premium hosting plan is aimed at the professional photographer with a large portfolio of images or for sale of high resolution images. Professional members can also utilise our blogging facilities.',
                      :disk_space => 500, :monthly_fee => 9.99, :commerce => 1, :blog => 1, :club => 1, :license => 1)
    end

    #create admin if user doesn't exist
    unless User.find_by_login('admin')
      user = User.new(:login => 'admin', :email => 'change@this.email', :no_terms => true, :admin => true, :password => 'secretadminpassword', :password_confirmation => 'secretadminpassword',
        :active => true, :activated => true, :host_plan_id => default.id, :vip => true)
      user.save!
    end
  end

  desc 'create accounting tables'
  task :create_account_tables => :environment do
    unless Account.find_by_code(1000)
      parent = Account.create(:name => 'Bank', :code => 1000, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Bank Account', :balance => 0)
      #
      acc = Account.new(:name => 'Paypal', :code => 1100, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'PayPal Account', :balance => 0)
      acc.parent = parent
      acc.save
    end
    unless Account.find_by_code(2000)
      parent = Account.create(:name => 'Income Accounts', :code => 2000, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Income Accounts', :balance => 0)
      #
      acc = Account.new(:name => 'Whitdrawl Admin Fees', :code => 2100, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Income from commission charged on credit withdrawals from the system.', :balance => 0)
      acc.parent = parent
      acc.save
      acc = Account.new(:name => 'Subscription Fees', :code => 2200, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Subscriptions Income', :balance => 0)
      acc.parent = parent
      acc.save
    end
    unless Account.find_by_code(3000)
      parent = Account.create(:name => 'Expence Accounts', :code => 3000, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Expence Accounts', :balance => 0)
      #
      acc = Account.new(:name => 'Paypal Commission', :code => 3100, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Paypal commissions charged to us on payments from clients', :balance => 0)
      acc.parent = parent
      acc.save
    end
    unless Account.find_by_code(4000)
      parent = Account.create(:name => 'Current Liability', :code => 4000, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Current Liabilities Accounts', :balance => 0)
      #
      acc = Account.new(:name => 'Client Credits Account', :code => 4100, :open_balance => 0, :open_balance_date => Time.now, :status => 1, :description => 'Client credits account.', :balance => 0)
      acc.parent = parent
      acc.save
    end
  end

  desc 'create main menu navigation data'
  task :create_main_menu_navigation_data => :environment do
    MenuItem.transaction do
      puts "Creating Home Menu"
      home = MenuItem.create(:name => 'Home', :link_type => 1, :link_url => '/home', :position => 10, :visible => true)
      home.children.create(:name => 'New Photos', :link_type => 1, :link_url => '/', :position => 10, :visible => true)
      home.children.create(:name => 'New Collections', :link_type => 1, :link_url => '/#recent_collection_link', :position => 20, :visible => true)
      home.children.create(:name => 'New Links', :link_type => 1, :link_url => '/#latest_links_link', :position => 30, :visible => true)
      home.children.create(:name => 'New Blogs', :link_type => 1, :link_url => '/#latest_blog_link', :position => 40, :visible => true)
      home.children.create(:name => 'New Topics', :link_type => 1, :link_url => '/#recent_topics_link', :position => 50, :visible => true)
      home.children.create(:name => 'New Comments', :link_type => 1, :link_url => '/#recent_comments_link', :position => 60, :visible => true)
      #
      puts "Creating Photos Menu"
      photo = MenuItem.create(:name => 'Photos', :link_type => 1, :link_url => '/photos/more_photos', :position => 20, :visible => true)
      photo.children.create(:name => 'Upload Photos', :link_type => 1, :link_url => '/photos/upload', :position => 10, :visible => true)
      photo.children.create(:name => 'Photos on Google Maps', :link_type => 1, :link_url => '/maps/photos', :position => 20, :visible => true)
      photo.children.create(:name => 'Top Photo Tags', :link_type => 1, :link_url => '/tags/photo', :position => 30, :visible => true)
      photo.children.create(:name => 'My Photos', :link_type => 1, :link_url => '/photos/mypictures', :position => 40, :visible => true)
      photo.children.create(:name => 'My Library', :link_type => 1, :link_url => '/photos/library', :position => 50, :visible => true)
      photo.children.create(:name => 'My Favourites', :link_type => 1, :link_url => '/photos/favourites', :position => 60, :visible => true)
      #
      puts "Creating Videos Menu"
      video = MenuItem.create(:name => 'Videos', :link_type => 1, :link_url => '/videos/index', :position => 23, :visible => true, :conditions => 'Configuration.module_videos')
      video.children.create(:name => 'Videos Index', :link_type => 1, :link_url => '/videos', :position => 5, :visible => true)
      video.children.create(:name => 'Upload Videos', :link_type => 1, :link_url => '/videos/upload', :position => 10, :visible => true)
      video.children.create(:name => 'Videos on Google Maps', :link_type => 1, :link_url => '/maps/videos', :position => 20, :visible => true)
      video.children.create(:name => 'Top Videos Tags', :link_type => 1, :link_url => '/tags/videos', :position => 30, :visible => true)
      video.children.create(:name => 'My Videos', :link_type => 1, :link_url => '/videos/my', :position => 40, :visible => true)
      video.children.create(:name => 'My Library', :link_type => 1, :link_url => '/videos/library', :position => 50, :visible => true)
      video.children.create(:name => 'My Favourites', :link_type => 1, :link_url => '/videos/favourites', :position => 60, :visible => true)
      #
      puts "Creating Audio Files Menu"
      audio = MenuItem.create(:name => 'Audio', :link_type => 1, :link_url => '/audios/index', :position => 26, :visible => true, :conditions => 'Configuration.module_audios')
      audio.children.create(:name => 'Audio Index', :link_type => 1, :link_url => '/audios', :position => 5, :visible => true)
      audio.children.create(:name => 'Upload Audio Files', :link_type => 1, :link_url => '/audios/upload', :position => 10, :visible => true)
      audio.children.create(:name => 'Audio on Google Maps', :link_type => 1, :link_url => '/maps/audios', :position => 20, :visible => true)
      audio.children.create(:name => 'Audio Tags', :link_type => 1, :link_url => '/tags/audios', :position => 30, :visible => true)
      audio.children.create(:name => 'My Audio Files', :link_type => 1, :link_url => '/audios/my', :position => 40, :visible => true)
      audio.children.create(:name => 'My Library', :link_type => 1, :link_url => '/audios/library', :position => 50, :visible => true)
      audio.children.create(:name => 'My Favourites', :link_type => 1, :link_url => '/audios/favourites', :position => 60, :visible => true)
      #
      puts "Creating Blogs Menu"
      blog = MenuItem.create(:name => 'Blogs', :link_type => 1, :link_url => '/blogs', :position => 30, :visible => true)
      blog.children.create(:name => 'New a New Blog', :link_type => 1, :link_url => '/blogs/my_blog', :position => 10, :visible => true)
      #
      puts "Creating News Menu"
      news = MenuItem.create(:name => 'News', :link_type => 1, :link_url => '/news', :position => 40, :visible => true)
      news.children.create(:name => 'Syndicated News', :link_type => 1, :link_url => '/news/syndicated', :position => 10, :visible => true)
      news.children.create(:name => 'Site News', :link_type => 1, :link_url => '/news/site', :position => 20, :visible => true)
      news.children.create(:name => 'Club News', :link_type => 1, :link_url => '/news/clubs', :position => 30, :visible => true)
      #
      puts "Creating Forums Menu"
      forum = MenuItem.create(:name => 'Forums', :link_type => 1, :link_url => '/forums', :position => 50, :visible => true, :conditions => 'Configuration.module_forums')
      #
      puts "Creating Photography Links Menu"
      links = MenuItem.create(:name => 'Links', :link_type => 1, :link_url => '/links', :position => 60, :visible => true, :conditions => 'Configuration.module_links')
      links.children.create(:name => 'Submit a Link', :link_type => 1, :link_url => '/links/add_link', :position => 10, :visible => true)
      links.children.create(:name => 'Popular Links', :link_type => 1, :link_url => '/links', :position => 20, :visible => true)
      links.children.create(:name => "Today's Link", :link_type => 1, :link_url => '/links/today', :position => 30, :visible => true)
      links.children.create(:name => "This Week's Links", :link_type => 1, :link_url => '/links/week', :position => 40, :visible => true)
      links.children.create(:name => "This Month's Links", :link_type => 1, :link_url => '/links/month', :position => 50, :visible => true)
      links.children.create(:name => 'My Submissions', :link_type => 1, :link_url => '/links/my_links', :position => 60, :visible => true)
      links.children.create(:name => 'My Favourite Links', :link_type => 1, :link_url => '/links/my_favourites', :position => 70, :visible => true)
      #
      puts "Creating Clubs Menu"
      club = MenuItem.create(:name => 'Clubs', :link_type => 1, :link_url => '/clubs', :position => 70, :visible => true)
      club.children.create(:name => 'Start a New Clubs', :link_type => 1, :link_url => '/clubs/my_club', :position => 10, :visible => true)
      #
      puts "Creating Album Menu"
      collect = MenuItem.create(:name => 'Albums', :link_type => 1, :link_url => '/collections', :position => 80, :visible => true)
      collect.children.create(:name => 'Create a new Album', :link_type => 1, :link_url => '/collections/new', :position => 10, :visible => true)
      #
      puts "Creating My Account Menu"
      account = MenuItem.create(:name => 'My Account', :link_type => 1, :link_url => '/account', :position => 90, :visible => true)
      account.children.create(:name => 'My Profile', :link_type => 1, :link_url => '/account', :position => 10, :visible => true)
      account.children.create(:name => 'My Blogs', :link_type => 1, :link_url => '/blogs/my_blog', :position => 20, :visible => true)
      account.children.create(:name => 'My Notifications', :link_type => 1, :link_url => '/notifications/my_notifications', :position => 30, :visible => true)
      account.children.create(:name => 'My Clubs', :link_type => 1, :link_url => '/clubs/my', :position => 40, :visible => true)
      account.children.create(:name => 'Accounting & Sales History', :link_type => 1, :link_url => '/orders/credit', :position => 50, :visible => true)
      account.children.create(:name => 'Hosting Plans', :link_type => 1, :link_url => '/account/account', :position => 60, :visible => true)
      #
      MenuItem.create(:name => 'Logout', :link_type => 1, :link_url => '/account/logout', :position => 100, :visible => true, :conditions => 'current_user')
      MenuItem.create(:name => 'Login', :link_type => 1, :link_url => '/account/login', :position => 110, :visible => true, :conditions => 'current_user.nil?')
      #
      MenuItem.create(:name => 'Administration', :link_type => 1, :link_url => '/admin/dashboard', :position => 1000, :visible => true, :conditions => 'current_user && current_user.admin?')
    end
  end

  desc 'clear and recreate main menu navigation data'
  task :recreate_main_menu_navigation_data => :environment do
    MenuItem.transaction do
      MenuItem.delete_all
      Rake::Task[ "photos:create_main_menu_navigation_data" ].invoke
    end
  end


  desc 'create default data'
  task :create_default_data => :environment do
    #create host plans
    Rake::Task[ "photos:create_default_host_plans" ].invoke
    #account tables
    Rake::Task[ "photos:create_account_tables" ].invoke
    Rake::Task[ "photos:create_main_menu_navigation_data" ].invoke
  end

  desc 'populate media preview width and height'
  task :populate_preview_dims => :environment do
    Photo.all.each do |photo|
      photo.query_preview_dimensions
      photo.save
      puts "processed id #{photo.id} with dims #{photo.preview_width} x #{photo.preview_height}"
    end
  end

  desc 'regenerate all photo views'
  task :regenerate_all_photo_views => :environment do
    Photo.all.each do |photo|
      photo.create_preview_and_thumbnail_files
      photo.save
      puts "processed id #{photo.id} with dims #{photo.preview_width} x #{photo.preview_height}"
    end
  end

  desc 'reswatch all photos'
  task :reswatch_all_photos => :environment do
    Photo.all.each do |photo|
      photo.swatch_from_image
      puts "processed id #{photo.id}"
    end
  end

  desc "recount category members"
  task :recount_categories => :environment do
    Category.all.each  do |cat|
      cat.members_count = cat.photos.count + cat.videos.count + cat.audios.count
      cat.save
    end
  end

  desc "migrate avatars to public"
  task :move_avatars_to_public => :environment do
    User.all.each do |user|
      unless user.avatar.blank?
        p "Processing #{user.login} avatar: #{user.avatar}"
        avatar_file = "#{RAILS_ROOT}/images/avatars/#{user.id}/#{user.avatar}"
        if File.exist?(avatar_file)
          dest_file = User.avatar_path(user, true)
          avatar_dir = File.dirname(dest_file)
          #
          p "found #{avatar_file}. Moving to #{dest_file}"
          #
          FileUtils.mkdir_p File.join(avatar_dir) unless File.exists?(File.join(avatar_dir))
          #do it
          FileUtils.mv avatar_file, dest_file
        end
      end
    end
  end

  
end
