class Menu < ActiveRecord::Base

  has_many :menu_items

  validates_presence_of   :name
  validates_uniqueness_of :name, :case_sensitive => false
  

end
