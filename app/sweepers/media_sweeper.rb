class  MediaSweeper < ActionController::Caching::Sweeper

  observe Audio, Video, Photo

  def after_create(record)
    expire_cache_for(record)
  end

  def after_update(record)
    expire_cache_for(record)
  end

  def after_destroy(record)
    expire_cache_for(record)
  end

  private

  def expire_cache_for(record)
    if record.is_a?(Audio)
      expire_fragment( 'more_audios' )
    elsif record.is_a?(Video)
      expire_fragment('videos')
    elsif record.is_a?(Photo)
      expire_fragment('more_photos')
    end  
  end


end