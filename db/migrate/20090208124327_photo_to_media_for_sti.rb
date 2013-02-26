class PhotoToMediaForSti < ActiveRecord::Migration
  def self.up
    #change commentable_type from Photo to Media
    Comment.transaction do
      Comment.update_all("commentable_type='Media'", 'commentable_type = "Photo"')
      Tagging.update_all("taggable_type='Media'", 'taggable_type = "Photo"')
      Marker.update_all("markable_type='Media'",  'markable_type = "Photo"')
      Favourite.update_all("favouriteable_type='Media'", 'favouriteable_type = "Photo"')
      Lightbox.update_all("link_type='Media'", 'link_type = "Photo"')
      ApprovalQueue.update_all("approvable_type='Media'", 'approvable_type = "Photo"')
      Rating.update_all("rateable_type='Media'", 'rateable_type = "Photo"')
    end
  end

  def self.down
    #change commentable_type from Media to Photo
    Comment.transaction do
      Comment.update_all("commentable_type='Photo'",  'commentable_type = "Media"')
      Tagging.update_all("taggable_type='Photo'",  'taggable_type = "Media"')
      Marker.update_all("markable_type='Photo'",  'markable_type = "Media"')
      Favourite.update_all("favouriteable_type='Photo'",  'favouriteable_type = "Media"')
      Lightbox.update_all("link_type='Photo'",  'link_type = "Media"')
      ApprovalQueue.update_all("approvable_type='Photo'",  'approvable_type = "Media"')
      Rating.update_all("rateable_type='Photo'", 'rateable_type = "Media"')
    end
  end
end
