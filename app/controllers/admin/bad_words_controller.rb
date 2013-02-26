class Admin::BadWordsController < Admin::BaseController

  active_scaffold :bad_word do |config|
    config.label = "Bad Word Filters"
    #columns
    config.list.columns   = [:id,  :word, :replaced_count]
    config.create.columns   = [:word]
    config.update.columns   = [:word]
  end 
  
end
