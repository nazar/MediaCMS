class Configuration < Setup

    @default_configuration = {
      'free_license'               => {:description => 'Default Free License'},
      'standard_license'           => {:description => 'Default Standard License'},
      'clubs_per_page'             => {:description => 'Clubs listed per page',                   :default => 30},
      'googlemap_key'              => {:description => 'Google Maps License Key'},
      'site_name'                  => {:description => 'Site Name (used in emails)'},
      'site_domain'                => {:description => 'Site Domain Name (used in emails)'},
      'site_admin'                 => {:description => 'Site Admin or Webmaster Email Address (used in emails)'},
      'forum_posts_per_page'       => {:description => 'Forum Posts Per Page',                    :default => 20},
      'forums_per_page'            => {:description => 'Forums Per Page',                         :default => 20},
      'blogs_per_page'             => {:description => 'Blog Entries Per Page',                   :default => 20},
      'photos_per_page'            => {:description => 'Photos Per Page',                         :default => 10},
      'more_photos_per_page'       => {:description => 'Photos Per Page in More Pages',           :default => 40},
      'photos_in_block'            => {:description => 'Number of Photos in a Block',             :default => 20},
      'photos_popup_resize_ratio'  => {:description => 'Resize Popup Photos by Factor:',           :default => 0.75},
      'videos_in_block'            => {:description => 'Number of Videos in a Block',             :default => 6},
      'photos_in_library_page'     => {:description => 'Number of Photos in Library Page',        :default => 20},
      'md5key'                     => {:description => 'MD5 Key',                                 :default => String.random_string(40)},
      'photo_default_price'        => {:description => 'Default Photo Price',                     :default => 1.0},
      'default_new_media_price'    => {:description => 'Default New Media Price',                 :default => 1.0},
      'sales_comission'            => {:description => 'Sales Commission Percentage',             :default => 0.15},
      'withdraw_fee'               => {:description => 'Paypal Withdrawl Administration Fee',     :default => 0.10},
      'payment_days'               => {:description => 'Waiting Period in Days to Process Credit Payment Request', :default => 14},
      'minimum_sale_value'         => {:description => 'Minimum Withdrawl Amount',                :default => 20.0},
      'order_minimum_credit'       => {:description => 'Minimum Credit Order',                    :default => 5.0},
      'anti_crawler'               => {:description => 'Anti Bad Crawler Measures',               :default => true},
      'queue_new_photos'           => {:description => 'Queue All New Photos for Approval',       :default => false},
      'queue_new_videos'           => {:description => 'Queue All New Videos for Approval',       :default => false},
      'queue_new_audios'           => {:description => 'Queue All New Audio Files for Approval',  :default => false},
      'multiple_resolution_prices' => {:description => 'Enable Multiple Resolution Photo Prices', :default => true},
      'multiple_license_prices'    => {:description => 'Enable Multiple License Photo Prices',    :default => true},
      'bad_word_filter'            => {:description => 'Enable Bad Word Filtering',               :default => false},
      'bad_word_filter_replace'    => {:description => 'Bad Words'},
      'anonymous_comments'         => {:description => 'Anonymous Users can Comment',             :default => false},
      'module_forums'              => {:description => 'Enable Forums Module',                    :default => true},
      'module_links'               => {:description => 'Enable Photography Links Module',         :default => true},
      'module_blogs'               => {:description => 'Enable Blogs Module',                     :default => true},
      'module_photos'              => {:description => 'Enable Photos Modules',                   :default => true},
      'module_videos'              => {:description => 'Enable Videos Modules',                   :default => true},
      'module_audios'              => {:description => 'Enable Audio File Module',                :default => true},
      'supported_image_types'      => {:description => 'Supported Image File Types',              :default => '.jpeg, .jpg, .gif, .png, .bmp'},
      'supported_video_types'      => {:description => 'Supported Video File Types',              :default => '.avi, .mpg, .mp4'},
      'supported_audio_types'      => {:description => 'Supported Audio File Types',              :default => '.mp3, .wav, .ogg'},
      'invoice_prefix'             => {:description => 'Prefix Invoice Number With'},
      'theme'                      => {:description => 'Use Theme',                               :default => 'panther'},
      'keywords'                   => {:description => 'Keywords Meta Tag'},
      'author'                     => {:description => 'Author Meta Tag',                         :default => 'FotoCMS.co.uk'},
      'copyright'                  => {:description => 'Copyright Meta Tag',                      :default => false},
      'pay_invoice_us'             => {:description => 'Enable Invoice Us Payments',              :default => false},
      'pay_paypal'                 => {:description => 'Enable Paypal Payments',                  :default => true},
      'pay_worldpay'               => {:description => 'Enable Worldpay Payments',                :default => false},
      'paypal_email'               => {:description => 'Paypal Payments Email'},
      'worldpay_security_key'      => {:description => 'Worldpay Security Key'},
      'test_payment_processing'    => {:description => 'Payment Gatway Test Mode',                :default => false},
      'medium_width'               => {:description => 'Medium Size Resize Image',                :default => 544},
      'medium_height'              => {:description => 'Medium Size Resize Height',               :default => 408},
      'thumbnail_width'            => {:description => 'Thumbnail Width',                         :default => 200},
      'thumbnail_height'           => {:description => 'Thumbnail Height',                        :default => 200},
      'images_annotate'            => {:description => 'Annotate Photo Previews',                 :default => true},
      'images_watermark'           => {:description => 'Watermark Photo Previews',                :default => true}, 
      'rss_page_size'              => {:description => 'RSS Items Per Page',                      :default => 20},
      'pic_lens_support'           => {:description => 'Enable Piclens Supports',                 :default => false},
      'collection_edit_display'    => {:description => 'Display media items in collection edit page', :default => 32},
      'video_snapshot_offset'      => {:description => 'Offset (in seconds) for Jpeg snapshot',   :default => 10},
      'video_max_length'           => {:description => 'Maximum Video Length (in seconds)',       :default => 0},
      'video_player_width'         => {:description => 'FLV Player Width',                        :default => 480},
      'video_player_height'        => {:description => 'FLV Player height',                       :default => 300},
      'audio_player_width'         => {:description => 'MP3 Player Width',                        :default => 400},
      'audio_player_height'        => {:description => 'MP3 Player height',                       :default => 360},
      'video_preview_width'        => {:description => 'FLV Preview Player Width',                :default => 300},
      'video_preview_height'       => {:description => 'FLV Previews Player height',              :default => 200},
      'audio_preview_width'        => {:description => 'MP3 Preview Player Width',                :default => 200},
      'audio_preview_height'       => {:description => 'MP3 Previews Player height',              :default => 125},
      'video_encode_width'         => {:description => 'Enable Piclens Supports',                 :default => 480},
      'video_encode_height'        => {:description => 'Enable Piclens Supports',                 :default => 360},
      'color_analysis_module'      => {:description => 'Color Analysis Search Module',            :default => true},
      'color_analysis_limit'       => {:description => 'Return Top x Colors Ssed',                :default => 10},
      'color_analysis_bits'        => {:description => 'Color Anlaysis Bits Resolution',          :default => 4},
      'color_analysis_colors'      => {:description => 'Color Analysis Reduce Number of Colors',  :default => 16},
      'preview_audio_bitrate'      => {:description => 'MP3 Preview Bitrate',                     :default => '56k'},
      'preview_audio_length'       => {:description => 'MP3 Preview Length',                      :default => '30'},
      'audio_free_full_preview'    => {:description => 'Free MP3 Full Length Preview',            :default => true}, 
      'enable_recaptcha'           => {:description => 'Enable ReCatcha for anonymous users',     :default => 'true'},
      'recaptcha_public_key'       => {:description => 'ReCatcha Public Key',                     :default => ''},
      'recaptcha_private_key'      => {:description => 'ReCatcha Private Key',                    :default => ''},
      'stats_tracking'             => {:description => 'Enable Stats Tracking',                   :default => true},
      'top_days_step'              => {:description => 'Top Media Days Window',                   :default => 60},              
      'purge_syndicated_items'     => {:description => 'Enable Stats Tracking',                   :default => 100}
    }
    
  def self.domain_of_site
    self.site_url.sub(/:\d+$/, '').sub('http://','')
  end

  def self.site_url
    "http://#{self.site_domain}"
  end


  def self.theme_to_location(item)
    if self.theme ==  'default'
      ''
    else
      "#{self.theme.downcase}/#{item}"
    end
  end

end
