module VideosHelper

  #render a preview sized video player
  def render_video_preview(video, player_options = {}, flash_options = {})
    player_options.merge!({:file => video.flv_file, :image => video.splash_file})
    #
    flash_options[:height]    ||= Setup.video_preview_height
    flash_options[:width]     ||= Setup.video_preview_width
    flash_options[:id]        ||= "video_#{video.id}"
    flash_options[:player_id] ||= "video_#{video.id}_player"
    #render jw player
    player(player_options, flash_options)
  end

  def render_video_view(video, player_options = {}, flash_options = {})
    player_options.merge!({:file => video.flv_file, :image => video.splash_file})
    #
    flash_options[:height]    ||= Setup.video_player_height
    flash_options[:width]     ||= Setup.video_player_width
    flash_options[:id]        ||= "video_#{video.id}"
    flash_options[:player_id] ||= "video_#{video.id}_player"
    #render jw player
    player(player_options, flash_options)
  end

  def render_video_splash(video, options={})
    if video
      options[:alt] ||= video.safe_title
      image_tag(video.splash_file, options)
    end
  end

  def video_price_options(video)
    options_by_id "video[#{video.id}][price]", { "Free" => "0", "One Credit" => "1" }, video.price.to_s
  end

  def render_most_viewed_videos
    videos = Video.most_popular(:limit => Configuration.videos_in_block*2);
    videos = random_select(videos, Configuration.videos_in_block)
    render_video_block(videos)
  end

  def render_most_talked_about_videos
    videos = Video.most_talked(:limit => Configuration.videos_in_block*2);
    videos = random_select(videos, Configuration.videos_in_block)
    render_video_block(videos)
  end

  def render_most_favourites_videos
    videos = Video.most_favourited(:limit => Configuration.videos_in_block*2);
    videos = random_select(videos, Configuration.videos_in_block)
    render_video_block(videos)
  end

  def render_best_selling_videos
    videos = Video.best_selling(:limit => Configuration.videos_in_block*2);
    videos = random_select(videos, Configuration.videos_in_block)
    render_video_block(videos)
  end

  def render_most_voted_videos
    videos = Video.most_voted(:limit => Configuration.videos_in_block * 2);
    videos = random_select(videos, Configuration.videos_in_block)
    render_video_block(videos)
  end

  def render_latest_top_videos
    #get double the photos and randomly show half of them
    videos = Video.latest_top_rated(Configuration.photos_in_block*2);
    videos = random_select(videos, Configuration.photos_in_block)
    render_video_block(videos)
  end

  def render_lastest_videos
    videos = Video.most_recent(:limit => Configuration.photos_in_block*2);
    videos = random_select(videos, Configuration.photos_in_block)
    render_video_block(videos)
  end

  def video_block(video)
    content_tag(:div, :class => 'list_videos') do
      render :partial => 'videos/video_preview', :locals => {:video => video}
    end  
  end

  def render_video_block(videos)
    body = ''
    if videos.length > 0
      for video in videos do
        body << video_block(video) unless video.nil?
      end
      body
    end
  end

  def video_popup(video)
    markaby do
      div :style => "width:#{video.preview_width.to_i}px; height:#{video.preview_height.to_i+50}px" do
        render_video_view(video, :autostart => 'true')
        div {strong video.title}
        div {video.formatted_description unless video.description.blank? || (video.description && (video.description == video.title))}
      end
    end
  end




end
