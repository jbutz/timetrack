ENV["RACK_ENV"] ||= "development"

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"].to_sym)
require 'chronic'
require 'json'
require 'mongoid'
require 'oauth2'
require 'securerandom'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/flash'
require 'uri'

unless ENV['SESSION_SECRET']
	ENV['SESSION_SECRET'] = SecureRandom.hex(16)
end

Mongoid.load!(File.expand_path(File.dirname(__FILE__) + "/mongoid.yml"))

Dir[
	File.expand_path('../../routes/*.rb', __FILE__),
	File.expand_path('../../models/*.rb', __FILE__),
	File.expand_path('../../lib/*.rb', __FILE__),
	File.expand_path('../../helpers.rb', __FILE__)].each do |path_name|
	require path_name
end