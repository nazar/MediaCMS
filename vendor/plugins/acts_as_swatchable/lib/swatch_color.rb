class SwatchColor < ActiveRecord::Base

  has_many :swatch_members
  has_many :swatches, :through => :swatch_members

  named_scope :by_component_threshold, lambda{|red, green, blue, threshold|
    {:conditions => ['red between ? and ? and green between ? and ? and blue between ? and ?', 
                     red - threshold, red + threshold, green - threshold, green + threshold, blue - threshold, blue + threshold]}
  }

  #class methods

  def self.top_swatch_colors_by_swatches_type(type)
    self.scoped( :conditions => ['swatch_colors.id in (select scj.swatch_color_id from swatch_color_join scj where scj.swatch_id in (select s.id from swatches s where s.swatchable_type = ?))', type],
                 :order => 'swatch_colors.swatches_count DESC')
  end

  #given a hex rgb string will pass r,g,b integers to block... ie hex_to_str('AABBCC'){|r,g,b| etc...}
  def self.hex_to_component(hex_str)
    if hex_str =~ /([A-F0-9]{2})([A-F0-9]{2})([A-F0-9]{2})/
      yield $1.hex, $2.hex, $3.hex if block_given?
    end
  end
  
  #instance methods

  def components_from_hex(rgb)
    SwatchColor.hex_to_component(rgb) do |r,g,b|
      self.red   = r
      self.green = g
      self.blue  = b
    end
  end

  def to_hex
    "##{rgb}"
  end



end