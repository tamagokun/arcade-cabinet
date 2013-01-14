$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'slim'
require 'sass'
require 'coffee-script'

require 'nokogiri'
require 'json'

require 'app'
