
class TimeTrack  < Sinatra::Base
	enable :sessions

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