# Initializes theme support by extending some of the core Rails classes
require 'patches/actionview_ex'
require 'patches/actioncontroller_ex'
require 'patches/actionmailer_ex'
require 'patches/routeset_ex'

# Add the tag helpers for rhtml and, optionally, liquid templates
require 'helpers/rhtml_theme_tags'

#need to add models path in each dir to Rails' $:
#Theme.add_theme_ruby_paths
