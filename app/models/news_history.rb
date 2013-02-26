class NewsHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :club
  belongs_to :news_item
  
  # class methods
  
  def NewsHistory.record_newsletter(club, news_item, user)
    NewsHistory.create(:club_id => club.id, :news_item_id => news_item.id, :user_id => user.id )
  end
  
  # instance methods
end

