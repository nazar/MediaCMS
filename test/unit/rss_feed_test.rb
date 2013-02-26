require File.dirname(__FILE__) + '/../test_helper'
require 'feedzirra'

class RssFeedTest < Test::Unit::TestCase

  context 'parse_rss_feeds' do

    setup do
      @fb_string    = File.read('/home/nazar/rails/photos.git/test/fixtures/files/feedburner.txt')
      @dpr_string   = File.read('/home/nazar/rails/photos.git/test/fixtures/files/dpreview.txt')
      @earth_string = File.read('/home/nazar/rails/photos.git/test/fixtures/files/earth_rss.txt')
    end

    context 'feed_burner' do

      setup do
        @feed = Feedzirra::Feed.parse @fb_string
      end

      should 'parse feed correctly' do
        assert_equal @feed.entries.length, 5
        assert_equal @feed.entries.first.title, "Typhoeus, the best Ruby HTTP client just got better"
        assert_equal @feed.entries.last.title, "First NYC Machine Learning Meetup"
      end

      context 'rss feed data tests' do

        setup do
          @rss_feed = RssFeed.create(:name => 'test', :url => 'test_url')
        end

        should 'process and cache feed' do
          RssFeed.update_feed_from_source(@rss_feed, :use_this_content => @fb_string)
          @rss_feed.reload
          #
          assert_equal @rss_feed.last_feed_date, @feed.last_modified
          #
          assert_equal @rss_feed.rss_feed_items.length, @feed.entries.length
          assert_equal @rss_feed.rss_feed_items.first.title, @feed.entries.first.title
        end

      end

    end

  end

end