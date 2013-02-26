class RssFeedItem < ActiveRecord::Base

  acts_as_commentable

  belongs_to :rss_feed

  named_scope :ordered, {:order => 'published DESC'}
  named_scope :oldest_first, {:order => 'published ASC'}

  #class methods

  def self.per_page
    10
  end

  def self.increment_views(rss_item)
    rss_item.views_count += 1
    rss_item.save
  end

  #instance methods

  def content_or_summary
    content || summary
  end



end
