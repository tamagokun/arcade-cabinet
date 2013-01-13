require File.expand_path(File.dirname(__FILE__) + '/app/boot')

require 'sprockets'

stylesheets = Sprockets::Environment.new
stylesheets.append_path 'app/assets/css'

javascripts = Sprockets::Environment.new
javascripts.append_path 'app/assets/js'

map("/css") { run stylesheets }
map("/js")  { run javascripts }

map("/")    { run FrontEnd::App }
