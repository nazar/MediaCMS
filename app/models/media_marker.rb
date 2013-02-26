class MediaMarker < Marker

  def self.by_media_type(klass)
    media_join = klass == klass.base_class ? '' : "and m.type = '#{klass.name}'"
    MediaMarker.scoped(:conditions => ["exists (select m.id from medias m where m.id = markers.markable_id #{media_join} and markers.markable_type = ?)", klass.base_class.to_s])
  end

  def self.by_media_type_in_collection(media_class, collection) 
    markers = self.by_media_type(media_class)
    markers = markers.scoped(:conditions => ['exists (select ci.item_id from collections_items ci where ci.item_id = markers.markable_id and ci.collection_id = ? and ci.item_type = ?)', collection.id, 'Media'])
    markers
  end

  def self.by_media_type_in_club(media_class, club)
    markers = self.by_media_type(media_class)
    markers = markers.scoped(:conditions => ['exists (select m.id from medias m where markers.markable_id = m.id and exists (select cm.user_id from club_members cm where cm.club_id = ? and cm.user_id = m.user_id))', club.id])
    markers
  end

end

