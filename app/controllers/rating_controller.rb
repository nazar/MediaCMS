class RatingController < ApplicationController

  def rate
    search_bot_allowed_here do
      rateable_type = params[:rating_type]
      rateable_id   = params[:id]
      rating        = params[:rating].to_i
      #sanitise
      if rating > 5
        rating = 5
      elsif rating < 0
        rating = 0
      end
      #get object
      @rateable = Rating.find_rateable(rateable_type, rateable_id)
      voted = false
      #logged in user can only vote once... ip addresses get three votes
      if logged_in?
        if current_user.id == @rateable.user_id
          render :update do |page|
            page.alert("Cannot rate own #{@rateable.class.to_s}.")
          end
          return
        end
        if Rating.count(:conditions => ['rateable_id = ? and rateable_type = ? and user_id = ?',
                                      params[:id],rateable_type,current_user.id]) > 0
          voted = true
        end
      else
        if Rating.count(:conditions => ['rateable_id = ? and rateable_type = ? and ip = ?',
                                      params[:id],rateable_type, request.remote_ip]) > 0
          voted = true
        end
      end
      #if voted then alert and bail
      if voted
        render :update do |page|
          page.alert("You've already voted")
        end
        return
      end
      #if here then ok to vote
      Rating.transaction do
        oRating = Rating.new( :rating => rating,
                              :ip => request.remote_ip,
                              :user_id => current_user ? current_user.id : 0 )
        @rateable.ratings_count += 1
        @rateable.rating_total += oRating.rating
        @rateable.save
        @rateable.add_rating oRating
        #class specific post processing, if any
        @rateable.post_rating_processing(oRating)
      end
      #clear cache
      expire_left_block
      #render update
      render :update do |page|
        page.replace_html "star-ratings-block", :partial => '/rating/rating', :locals => { :rateable => @rateable }
      end
    end
  end
  
end
