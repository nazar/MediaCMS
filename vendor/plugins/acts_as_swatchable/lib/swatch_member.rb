class SwatchMember < ActiveRecord::Base

  belongs_to :swatch
  belongs_to :swatch_color

  #class methods

  def self.ordered_swatch_ids_by_color_and_position(a,b,c,d,e,f,g,h,position,options={})
    ids = self.all({:select => "swatch_id, abs(position - #{position}) pos", :order => "abs(position - #{position})",
                     :conditions => ['swatch_color_id in ' <<
                              '  (select sc.id from swatch_colors sc where red between ? and ? and green between ? and ? and blue between ? and ?) '<<
                              '   and position between ? and ?', a,b,c,d,e,f,g,h ]
                     }.merge(options))
    ids.sort{|aa,bb|aa.pos.to_i <=> bb.pos.to_i}.collect{|aa| aa.swatch_id}
  end



end