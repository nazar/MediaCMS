class NewsTopic < ActiveRecord::Base
  has_many :news_items, :as => :itemable
end
