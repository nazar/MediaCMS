#monkey patch base classes to add useful functionality

class String

  def self.random_string(len)
    rand_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" << "0123456789" << "abcdefghijklmnopqrstuvwxyz"
    rand_max = rand_chars.size
    ret = ""
    len.times{ ret << rand_chars[rand(rand_max)] }
    ret
  end

  def to_permalink
    self.gsub(/[^-_\s\w]/, ' ').downcase.squeeze(' ').tr(' ','-').gsub(/-+$/,'')
  end

end

class Numeric

  def commify(dec='.', sep=',')
    num = to_s.sub(/\./, dec)
    dec = Regexp.escape dec
    num.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*#{dec})/, "\\1#{sep}").reverse
  end

  def to_time_stamp
    [self/3600, self/60 % 60, self % 60].map{|t| t.to_s.rjust(2, '0')}.join(':')
  end

end

class Time

  def english_date
    self.strftime '%d/%m/%Y %H:%M:%S' unless self.nil?
  end

end

class ActiveRecord::Base

  def self.scope_or_yield(scope, &block)
    if block_given?
      scope.collect{|c| block.call(c)}.length > 0
    else
      scope
    end
  end

end
