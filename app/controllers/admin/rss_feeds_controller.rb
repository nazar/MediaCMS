class Admin::RssFeedsController < Admin::BaseController

  active_scaffold :rss_feed do |config|
    config.label = "RSS Feeds Maintenance"
    config.list.columns   = [:name, :description, :url, :display_order, :limit_items, :visible, :update_frequency, :last_feed_date, :next_update]
    config.update.columns = [:name, :description, :url, :display_order, :limit_items, :visible, :update_frequency, :next_update]
    config.create.columns = [:name, :description, :url, :display_order, :limit_items, :visible, :update_frequency]
  end

end
