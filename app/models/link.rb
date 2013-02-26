class Link < ActiveRecord::Base
  
  acts_as_commentable
  acts_as_rateable
  acts_as_favouriteable
  
  belongs_to :user
  
  validates_presence_of 'name'
  validates_presence_of 'link'


  #class methods
  
  def self.popular_links(limit = 20, current_user = nil)
    id = current_user ? current_user.id : 0
    Link.scoped( :select => 'links.*, favourites.id saved',
                    :joins => "left join favourites on links.id = favourites.favouriteable_id and favourites.favouriteable_type = 'Link' and favourites.user_id = #{id}",
                    :order => 'Date(links.created_at) DESC, votes_up DESC' ,
                    :limit => limit)    
  end
  
  def self.get_user_links(user)
    Link.scoped( :conditions => ['links.user_id = ?',user.id], 
      :select => 'links.*, favourites.id saved',
      :joins => "left join favourites on links.id = favourites.favouriteable_id and favourites.favouriteable_type = 'Link' and favourites.user_id = #{user.id}",
      :order => 'links.created_at DESC')
  end
  
  def self.get_my_favourites(user)
    Link.scoped( :conditions => ['links.user_id = ?',user.id],
      :select => 'links.*, 1 saved',
      :joins => "inner join favourites on links.id = favourites.favouriteable_id and favourites.favouriteable_type = 'Link' and favourites.user_id = #{user.id}",
      :order => 'links.created_at DESC')
    
  end
  
  def self.get_popular_links(limit = 50)
    #keep this basic for the time being
    Link.scoped( :limit => limit, :order => 'Date(created_at) DESC, votes_up DESC')
  end
  
  def self.search(search_str, user=nil)
    id = user.nil? ? 0 : user.id
    Link.scoped(:select => 'links.*, favourites.id saved',
              :conditions => ['name like ? or description like ?',"%#{search_str}%","%#{search_str}%"],
              :joins => "left join favourites on links.id = favourites.favouriteable_id and favourites.favouriteable_type = 'Link' and favourites.user_id = #{id}",
              :order => 'Date(links.created_at) DESC, votes_up DESC')
  end

  #instance methods
  
  def domain
    link[/^(?:[^\/]+:\/\/)?([^\/:]+)/ ]
  end
  
  def safe_name
    name.to_permalink
  end
  
  def lookup_saved(user)
    if user
      Favourite.find_favourites_for_favouriteable(self.id, 'Link').by_user(user).count >  0
    else
      false
    end
  end
  
  def title
    name
  end
  
  def bookmark_title
    name.gsub(' ','+')
  end

  def perma_title
    name
  end

  def increment_views
    self.views += 1
    self.save
  end
  
  def increment_clicks
    self.visits += 1
    self.save    
  end
  
  def increment_vote
    self.votes_up += 1
    self.save
  end
  
  def increment_favourited
    self.saved_count += 1
    self.save
  end

  def formatted_description
    Misc.format_red_cloth(description) if description
  end
  
  def name
    BadWord.filter_bad_words(read_attribute(:name))
  end
  
  def description
    BadWord.filter_bad_words(read_attribute(:description))
  end
  
  
end
