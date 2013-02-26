class Search

  TypeNameDesc    = 0
  TypeCategories  = 1
  TypeTags        = 2
  TypeAuthors     = 3
  TypeBlogs       = 4
  TypeForums      = 5
  TypeCollections = 6                                                     
  TypeWebLinks    = 7

  def self.search_types
    base = {Search::TypeNameDesc => 'by name, description or id', Search::TypeCategories => 'by categories',
     Search::TypeTags => 'by tags', Search::TypeAuthors => 'for Media Authors', Search::TypeCollections => 'in Collections'}
    #optional search options depending on active modules
    base.merge!({Search::TypeBlogs => 'in Blogs'}) if Configuration.module_blogs
    base.merge!({Search::TypeForums => 'in Forums'}) if Configuration.module_forums
    base.merge!({Search::TypeWebLinks => 'in Web Links'}) if Configuration.module_links
    base
  end


end