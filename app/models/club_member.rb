class ClubMember < ActiveRecord::Base
  
  belongs_to :club
  belongs_to :user
  
  #class methods

  StatusNotApproved   = 0
  StatusSuspended     = 1
  StatusActive        = 2
  StatusModerator     = 5
  StatusAdministrator = 10

  def self.status_types
    {ClubMember::StatusNotApproved =>'Not Approved', ClubMember::StatusSuspended => 'Suspended',
     ClubMember::StatusActive => 'Active', ClubMember::StatusModerator => 'Moderator',
     ClubMember.StatusAdministrator => 'Administrator'}
  end
  
  def self.add_to_club(club, user, params={})
    #don't add if exists
    if club.club_members.find_by_user_id(user).blank?
      member = ClubMember.create( :user_id => user.id, :club_id => club.id, :application => params[:application], 
                                  :status => club.free ? 2 : 0, :status_date => Time.now)
      #increment member count if free to join
      if club.free
        club.members_count += 1
        club.save
      end
      member
    end
  end
  
  #instance methods
  
  def status_desc
    ClubMember.status_types[status]
  end
  
  def markup_application
    Misc.format_red_cloth(application) if application
  end
  
end
