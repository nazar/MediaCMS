class License < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :medias
  has_many :photos
  has_many :videos
  has_many :audios

  validates_presence_of :name
  validates_presence_of :description
  
  #class methods
  
  def self.get_all_and_user_licenses(user)
    all  = self.find(:all, :conditions => ['user_id in (0,?)',user.id], :order => 'user_id')
    mine = []
    all.each{|l| mine << l if l.user_id == user.id }
    all  = all - mine      
    #
    return all, mine
  end
  
  def self.all_licenses_for_user(user)
    License.find(:all, :conditions => ['user_id in (0,?)',user.id], :order => 'user_id')    
  end
  
  def self.panther_licenses
    License.find(:all, :conditions => ['user_id = ?',0], :order => 'name')
  end
  
  def self.user_licenses(user)
    License.find(:all, :conditions => ["user_id = ?", user.id], :order => 'name')
  end
  
  #instance methods
    
  def excerpt(length = 100)
    if description.length > 0
      description[0..length] << '...'
    else
      description
    end
  end
	
	def html_description
		if description
		  Misc.format_red_cloth(description)
		else
			''
		end
  end
  
end
