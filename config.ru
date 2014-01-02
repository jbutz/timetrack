require 'rubygems'
require 'bundler'
require 'uri'

use Rack::Session::Cookie, :key => 'rack.session',
						   :path => '/',
						   :expire_after => 14400, # In seconds
						   :secret => 'd34ef0c4018d25c10f3f2367144beba8'
Bundler.require

require File.expand_path(File.dirname(__FILE__) + '/app')
Mongoid.load!(File.expand_path(File.dirname(__FILE__) + "/config/mongoid.yml"))

run TimeTrack