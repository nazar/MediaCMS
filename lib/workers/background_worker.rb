class BackgroundWorker

  include BackgroundFu::WorkerMonitoring

  #post process an uploaded photo by creating previews and thumbnails
  def process_uploaded_photo(args)
    unless args[:photo_id].nil?
      Photo.create_preview_and_thumbnail_files_by_id args[:photo_id]
    end
  end

  def process_uploaded_video(args)
    unless args[:video_id].nil?
      video = Video.find_by_id args[:video_id]
      video.convert_to_flash_and_generate_splash { |progress| record_progress(progress) }
      video.state = 10
      video.save!
    end
  end

  def process_uploaded_audio(args)
    unless args[:audio_id].nil?
      audio = Audio.find_by_id args[:audio_id]
      audio.convert_to_mp3 { |progress| record_progress(progress) }
      audio.state = 10
      audio.save!
    end
  end

  def prepare_collection_cache(args)
    collection = Collection.find(args[:collection_id])
    user       = User.find(args[:user_id])
    #create & notify user with download link
    collection.download_collection
    UserMailer.deliver_collection_download_ready(collection, user)
  end

  def recode_all_user_audio(args)
    user = User.find args[:user_id]
    Audio.recode_all_audio_for_user(user)
    UserMailer.deliver_audio_recode_complete(user)
  end

  def recode_audio(args)
    audio = Audio.find args[:audio_id]
    audio.convert_to_mp3
  end

  
end