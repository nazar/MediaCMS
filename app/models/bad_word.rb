class BadWord < ActiveRecord::Base
  
  def self.enabled?
    Configuration.bad_word_filter
  end
  
  def self.filter_bad_words(text)
    if self.enabled? && text
      #construct regex to search all all defined bad words and replace with Configuration.bad_word_filter_replace
      words = self.find(:all).collect{|word| word.word}.join('|')
      if words && (words.length > 0)
        words = Regexp.new(words)
        return text.gsub(words, Configuration.bad_word_filter_replace)
      else
        text
      end
    else
      text
    end
  end
  
end
