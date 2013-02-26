module AccountHelper
  def recalc_space(user)
    page.replace 'disk_space',  :partial => '/account/disk_space', :locals => {:user => user}
  end
end