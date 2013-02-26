class Friend < ActiveRecord::Base
  belongs_to :me, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :my_friend, :class_name => 'User', :foreign_key => 'friend_id'
  
  #class methods
  
  def Friend.add_friend(me, friend, comment)
    Friend.transaction do
      #link me to friend and vice versa
      Friend.create( :user_id => me.id, :friend_id => friend.id, :comments => comment)
      Friend.create( :user_id => friend.id, :friend_id => me.id, :comments => comment)
      #increment friends count for each
      me.friends_count += 1
      me.save
      
      friend.friends_count += 1
      friend.save
    end
  end
   
end
