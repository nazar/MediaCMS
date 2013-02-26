module AudiosHelper

  def audio_price_options(audio)
    options_by_id "audio[#{audio.id}][price]", { "Free" => "0", "One Credit" => "1" }, audio.price.to_s
  end

  #render a preview sized audio player
  def render_audio_preview(audio, player_options = {}, flash_options = {})
    player_options.merge!({:file => audio.preview_file,  :plugins => '/swf/plugins/ifequalizer',
                           :skin => 'simple', :id => "audio_#{audio.id}_player", :image => audio.splash_file})
    #
    flash_options[:height]    ||= Configuration.audio_preview_height
    flash_options[:width]     ||= Configuration.audio_preview_width
    flash_options[:id]        ||= "audio_#{audio.id}_player"
    flash_options[:player_id] ||= "audio_#{audio.id}_player"
    flash_options[:name]      ||= "audio_#{audio.id}_player"
    flash_options[:class]     ||= "audio_preview"
    #render jw player
    player(player_options, flash_options)
  end

  def render_audio_list(audio, player_options = {}, flash_options = {})
    prefix = player_options.delete(:prefix)
    id     = prefix.blank? ? "audio_#{audio.id}_player" : "#{prefix}_audio_#{audio.id}_player"
    #
    player_options.merge!({:file => audio.preview_file,  :plugins => '/swf/plugins/ifequalizer',
                           :skin => 'simple', :id => id, :image => audio.splash_file})
    #
    flash_options[:height]    ||= 100
    flash_options[:width]     ||= 130
    flash_options[:id]        ||= id
    flash_options[:player_id] ||= id
    flash_options[:name]      ||= id
    flash_options[:class]     ||= "audio_preview"
    #render jw player
    player(player_options, flash_options)
  end

  def render_audio_view(audio, player_options = {}, flash_options = {})
    player_options.merge!({:file => audio.preview_file, :plugins => '/swf/plugins/ifequalizer', :skin => 'simple',
                           :id => "audio_#{audio.id}_player", :image => audio.splash_file})
    #
    flash_options[:height]    ||= Configuration.audio_player_height
    flash_options[:width]     ||= Configuration.audio_player_width
    flash_options[:id]        ||= "audio_#{audio.id}_player"
    flash_options[:player_id] ||= "audio_#{audio.id}_player"
    flash_options[:name]      ||= "audio_#{audio.id}_player"
    flash_options[:class]     ||= "audio_view"
    #render jw player
    player(player_options, flash_options)
  end

  def render_most_viewed_audios
    if ( medias = Audio.most_popular(:limit => Configuration.photos_in_block*2))
      medias = random_select(medias, Configuration.photos_in_block)
      render_audio_block(medias, 'recent')
    end  
  end

  def render_most_voted_audios
    if ( medias = Audio.most_voted(:limit => Configuration.photos_in_block*2))
      medias = random_select(medias, Configuration.photos_in_block)
      render_audio_block(medias, 'vote')
    end
  end

  def render_most_talked_about_audios
    if ( medias = Audio.most_talked(:limit => Configuration.photos_in_block*2))
      medias = random_select(medias, Configuration.photos_in_block)
      render_audio_block(medias, 'comment')
    end
  end

  def render_most_favourites_audios
    if ( medias = Audio.most_favourited(:limit => Configuration.photos_in_block*2))
      medias = random_select(medias, Configuration.photos_in_block)
      render_audio_block(medias, 'favourite')
    end
  end

  def render_best_selling_audios
    if ( medias = Audio.most_talked(:limit => Configuration.photos_in_block*2))
      medias = random_select(medias, Configuration.photos_in_block)
      render_audio_block(medias, 'selling')
    end
  end

  def render_most_recent_audios
    if ( medias = Audio.most_recent(:limit => Configuration.photos_in_block*2))
      medias = random_select(medias, Configuration.photos_in_block)
      render_audio_block(medias, 'recent')
    end
  end

  def audio_block(audio, prefix)
    content_tag(:div, :class => 'list_audios') do
      render :partial => 'audios/audio_preview', :locals => {:audio => audio, :prefix => prefix}
    end
  end

  def render_audio_block(audios, prefix='')
    body = ''
    if audios.length > 0
      for audio in audios do
        body << audio_block(audio, prefix) unless audio.nil?
      end
      body
    end
  end

  def audio_popup(audio)
    markaby do
      div :style => "width:#{Configuration.audio_preview_width}px; height:#{Configuration.audio_preview_height + 20}px" do
        render_audio_preview(audio, :autostart => 'true')
        div {strong audio.title}
        div {audio.formatted_description unless audio.description.blank? || (audio.description && (audio.description == audio.title))}
      end
    end
  end




end
