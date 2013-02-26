class ClubsController < ApplicationController

  helper :markup, :render_blocks, :tags, :feed, :photos, :news
  
  helper :maps  
  include MapsHelper
  
  before_filter :login_required, :except => [:view, :index, :apply, :markers]
  
         
  def index
    @clubs = Club.paginate :page => params[:page], :per_page => Configuration.clubs_per_page, :order => 'name'
#    @tags, @min_count, @max_count = Club.top_tags_min_max(50)
    @page_title = 'Viewing all Clubs'
  end
  
  def my
    @club  = Club.new
    @clubs = current_user.clubs
    @clubs_joined = current_user.club_memberships
    @page_title = 'My Clubs & Club Memberships'
  end

  def new
    can_add_club do
      @club = Club.new
      @page_title = 'Add a new Club'
      #
      return unless request.post?
      Club.transaction do
        @club.attributes = params[:club]
        @club.user = current_user
        #add owner to club_members
        member = ClubMember.add_to_club(@club, current_user)
        member.status = 10
        member.save
      end
      if @club.save
        redirect_to club_my_path
      end
    end  
  end
  
  def edit
    @club = Club.find_by_id(params[:id])
    can_admin_club(@club) do
      @page_title = 'My Clubs & Club Memberships'
      #
      return unless request.post?
      @club.attributes = params[:club]
      if @club.save
        redirect_to club_my_path
      end
    end
  end

  def delete
    club = Club.find_by_id(params[:id])
    can_admin_club(club) do
      #Club destroy callback clear dependancies
      Club.transaction do
        club.destroy;
      end
      redirect_to club_my_path
    end
  end
  
  def view
    @club = Club.find_by_id(params[:id])
    unless @club.blank?
      @best_photos = Club.best_photos(@club, :limit => Configuration.photos_per_page * 2)
      @latest_photos = Club.latest_photos(@club, :limit => Configuration.photos_per_page * 2)
      @club_admin = current_user && (current_user.id == @club.user_id)
      @forums = @club.forums_for_user(current_user)
      @page_title = "View Club #{@club.name}"
    else
      render :text => 'Club does not exist', :status => 404
    end
  end

  def apply
    if not logged_in?
      render :update do |page|
        page.alert('You must be registered and logged in to join this club')
      end
      return
    end
    club = Club.find(params[:id])
    #add user to club
    Club.transaction do
      member = ClubMember.add_to_club(club, current_user)
      UserMailer.deliver_club_application(club, member) if not club.free
    end
    #
    render :update do |page|
      if club.free
        page.replace_html 'club_members', 
                 :partial => 'clubs/club_members', 
                 :locals => {:club_members => club.active_club_members}
        page.alert "Thank you for joining #{club.name}"
      else
        page.alert 'The club owner has been notified of your application.'
      end  
    end
  end

  def new_news_item
    return (redirect_to club_news_admin_path) unless params[:cancel].nil?
    @club = Club.find_by_id(params[:club_id])
    can_admin_club(@club) do
      @mail = true
      @news_item = @club.news_items.build
      @page_title = 'Creating a new Club News Items'
      return unless request.post?
      #
      @news_item.attributes = params[:news_item]
      @news_item.user = current_user
      @news_item.itemable = @club
      #
      if @news_item.save
        #mailing list?
        if params[:mail_members].to_i ==  1
          UserMailer.deliver_news_to_club_members(@club, @news_item)
          NewsHistory.record_newsletter(@club, @news_item, current_user)
        end
        #
        redirect_to club_news_admin_path
      end
    end
  end
  
  def edit_news_item
    return (redirect_to club_news_admin_path) unless params[:cancel].nil?
    @news_item = NewsItem.find_by_id(params[:id])
    can_admin_club(@news_item.itemable) do
      @page_title = "Editing #{@news_item.title}"
      #
      return unless request.post?
      #
      @news_item.attributes = params[:news_item]
      redirect_to club_news_admin_path if @news_item.save
    end
  end
  
  def resend_news_item
    item = NewsItem.find(params[:id])
    if current_user.id == item.itemable.user_id
      UserMailer.deliver_news_to_club_members(item.itemable, item)
      NewsHistory.record_newsletter(item.itemable, item, current_user)
      render :update do |page|
        page.replace_html 'news_histories', :partial => 'news_histories/histories',
                                            :locals => {:histories => item.itemable.news_histories}
      end
    else
      render :nothing => true
    end
  end
  
  def admin_news
    @club = Club.find(:first, params[:club_id])
    can_admin_club(@club) do
      @news_item = NewsItem.new
      @page_title = "Managing News for Club #{@club.name}"
    end
  end
  
  def view_applications
    @club = Club.find(params[:id])
    can_admin_club(@club) do
      @page_title = "Viewing Club #{@club.name} Membership Applications"
    end
  end
  
  def approve_membership
    member = ClubMember.find(params[:id])
    club   = member.club
    can_admin_club(club) do
      Club.transaction do
        member.status = 2
        club.members_count += 1
        member.save
        club.save
        UserMailer.deliver_membership_approved(member)
        render :update do |page|
          page.replace_html('applicants', :partial => 'clubs/club_applicants', :locals => {:club => club})
        end
      end
    end
  end
  
  def decline_membership
    member = ClubMember.find(params[:id])
    club   = member.club
    can_admin_club(club) do
      UserMailer.deliver_membership_declined(member)
      member.destroy
      render :update do |page|
        page.replace_html('applicants', :partial => 'clubs/club_applicants', :locals => {:club => club})
      end
    end
  end
  
  def markers
    club = Club.find(params[:id])
    render :text => markers_to_markup(club.photo_markers)
  end
  
  def admin_forums
    @club = Club.find_by_id(params[:club_id])
    can_admin_club(@club) do
      @page_title = "Managing #{@club.name} Forums"
    end
  end

  def new_club_forum
    @club = Club.find_by_id(params[:club_id])
    return (redirect_to club_forum_admin_path(@club)) unless params[:cancel].nil?
    can_admin_club(@club) do
      @forum              = @club.forums.build(:position => @club.forums.count * 10)
      @page_title         = "Create a New Forum"
      #
      return unless request.post?
      #
      @forum.attributes = params[:forum]
      @forum.created_by = current_user.id
      #
      redirect_to club_forum_admin_path(@club) if @forum.save
    end
  end

  def edit_club_forum
    @forum = Forum.find_by_id(params[:id])
    @club  = @forum.club
    return (redirect_to club_forum_admin_path(@club)) unless params[:cancel].nil?
    can_admin_club(@club) do
      @page_title         = "Editing Club Forum #{@forum.name}"
      #
      return unless request.post?
      #
      @forum.attributes = params[:forum]
      #
      redirect_to club_forum_admin_path(@club) if @forum.save
    end
  end

  protected

  def can_add_club
    if logged_in? && current_user.host_plan.create_club
      yield
    else
      step_notice('Your host plan does not allow adding clubs')
    end
  end

  def can_admin_club(club)
    if club.is_club_admin(current_user)  || admin?
      yield
    else
      step_notice('Not authorised')
    end
  end
  
end