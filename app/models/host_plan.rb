class HostPlan < ActiveRecord::Base
  has_many :users 
  
  def self.defaultPlan
    self.find(:first, :conditions => "default_plan = 1")
  end
  
  def self.paid_host_plans
    self.find(:all, :conditions => 'monthly_fee > 0')
  end
  
  def can_blog
    blog == 1
  end

  def can_set_price
    price_setting == 1
  end

  def can_sell
    commerce == 1
  end
  
  def own_license
    license == 1
  end
  
  def create_club
    club == 1
  end
  
  def license_type
    if can_sell
      if own_license
        'Define you own licenses + standard licenses'
      else
        "Standard #{Configuration.site_name} Licenses"
      end
    else
      'Free license'
    end
  end
  
  def disk_space_bytes
    return self.disk_space * 1024 * 1024
  end
  
end
