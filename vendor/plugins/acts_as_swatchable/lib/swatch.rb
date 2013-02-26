class Swatch < ActiveRecord::Base

  belongs_to :swatchable, :polymorphic => true

  has_many :swatch_members, :order => 'position',
    :after_add => :increment_count, :after_remove => :decrement_count, :dependent => :destroy
  has_many :swatch_colors, :through => :swatch_members, :order => 'position'
  
  named_scope :by_type, lambda{|type|
    {:conditions => ['swatchable_type = ?',type]}
  }

  #class methods

  def self.swatch_for_swatchable(objekt)
    self.first :conditions => ['swatchable_id = ? and swatchable_type = ?', objekt.id, objekt.class.to_s.constantize.base_class.to_s]
  end

  def self.swatachable_ids_by_type_and_member(type, member, options={})
    unless member.nil?
      if color = member.swatch_color
        a,b,c,d,e,f = self.safe_range(color.red, color.green, color.blue, options.delete(:threshold))
        g,h         = self.safe_range(member.position, options.delete(:pos_threshold))
        #order swatch ids
        ids = SwatchMember.ordered_swatch_ids_by_color_and_position(a,b,c,d,e,f,g,h, member.position)
        swatchable_ids = self.by_type(type).all(:select => 'id, swatchable_id', :conditions => {:id => ids})
        #sort returned array by position on id in ids array
        swatchable_ids.sort{|aa,bb| ids.index(aa.id) <=> ids.index(bb.id)}.collect{|aa| aa.swatchable_id}
      end
    end
  end

  def self.swatachable_ids_by_type_and_color(type, color, position, options={})
    SwatchColor.hex_to_component(color) do |red, green, blue|
      a,b,c,d,e,f = self.safe_range(red, green, blue, options[:threshold])
      #order swatch ids
      ids = SwatchMember.ordered_swatch_ids_by_color_and_position(a,b,c,d,e,f,0,10, position)
      swatchable_ids = self.by_type(type).all(:select => 'id, swatchable_id', :conditions => {:id => ids})
      #sort returned array by position on id in ids array
      swatchable_ids.sort{|aa,bb| ids.index(aa.id) <=> ids.index(bb.id)}.collect{|aa| aa.swatchable_id}
    end
  end

  #instance methods

  def add_if_not_exists(rgb, position)
    color = SwatchColor.find_or_initialize_by_rgb(rgb)
    if color.new_record?
      color.components_from_hex(rgb)
      color.save!
    end
    swatch_members.create(:swatch_color_id => color.id, :position => position)
  end

  protected

  def self.safe_range(*args)
    def self.calc_pair(value, diff)
      a = value - diff
      if a < 0
        diff += a.abs; a=0
      end
      b = value + diff
      #
      return a,b
    end
    diff = args.delete_at(args.length-1)
    #
    a,b = self.calc_pair(args[0], diff)
    return a,b if args.length == 1
    #
    c,d = self.calc_pair(args[1], diff)
    return a,b,c,d if args.length == 2
    #
    e,f = self.calc_pair(args[2], diff)
    return a,b,c,d,e,f if args.length == 3
  end

  #cater for inheritable STI table models
  def swatchable_type=(type)
    super(type.to_s.constantize.base_class.to_s)
  end

  protected

  #update cache in both relationships
  def increment_count(member)
    #color needs to know that it has been added to this swatch
    member.swatch_color.swatches_count += 1
    member.swatch_color.save!
  end

  #update cache in both relationships
  def decrement_count(member)
    #color needs to know that it has been added to this swatch
    if member.swatch_color.swatches_count > 1
      member.swatch_color.swatches_count -= 1
      member.swatch_color.save
    elsif member.swatch_color.swatches_count == 1 #not on any swatch.. delete
      member.swatch_color.destroy
    end
  end

end