require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require "sinatra/config_file"
require 'mongoid'
require 'json'
require 'oauth2'
require 'chronic'

require_relative 'helpers'
require_relative 'lib/punch_time'
require_relative 'models/punch'
require_relative 'routes/main'
require_relative 'routes/history'
require_relative 'routes/edit'
require_relative 'routes/punching'

# enable :sessions

##
# Scopes are space separated strings
SCOPES = [
	'https://www.googleapis.com/auth/userinfo.email'
].join(' ')

unless G_API_CLIENT = ENV['G_API_CLIENT']
	raise "You must specify the G_API_CLIENT env variable"
end

unless G_API_SECRET = ENV['G_API_SECRET']
	raise "You must specify the G_API_SECRET env variable"
end

unless VALID_EMAIL = ENV['VALID_EMAIL']
	raise "You must specify the VALID_EMAIL env variable"
end

class TimeTrack  < Sinatra::Base
	#enable :sessions

	set :root, File.dirname(__FILE__)

	set(:auth) do |auth|
		condition do
			unless session[:authenticated]
				redirect "/", 303
			end
		end
	end

	helpers Sinatra::TimeTrack::Helpers

	register Sinatra::ConfigFile
	register Sinatra::Flash

	register Sinatra::TimeTrack::Routing::Main
	register Sinatra::TimeTrack::Routing::History
	register Sinatra::TimeTrack::Routing::Edit
	register Sinatra::TimeTrack::Routing::Punching

	config_file File.dirname(__FILE__) + '/config/config.yml'
	
end