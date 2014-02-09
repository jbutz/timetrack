module Sinatra
module TimeTrack
module Routing
	module Main
		def self.registered(app)

			app.get '/' do
				@authenticated = session[:authenticated]
				@openpunch = Punch.where(out: nil).first
				@now = PunchTime.new( settings.timezoneName ).now.to_display

				response['Cache-Control'] = 'no-cache, no-store, must-revalidate'
				response['Pragma'] = 'no-cache'
				response['Expires'] = '0'
				erb :index
			end

			app.get "/auth" do
				redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri(request),:scope => 'https://www.googleapis.com/auth/userinfo.email',:access_type => "online")
			end

			app.get '/oauth2callback' do
				access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri(request))
				session[:access_token] = access_token.token
				@message = "Successfully authenticated with the server"
				@access_token = session[:access_token]

				# parsed is a handy method on an OAuth2::Response object that will
				# intelligently try and parse the response.body
				response = access_token.get('https://www.googleapis.com/userinfo/email?alt=json')
				session[:email] = response.parsed['data']['email']
				session[:authenticated] = ENV['VALID_EMAIL'].include? session[:email]

				if session[:authenticated]
					redirect to('/')
				else
					erb :fail
				end
			end
		end
	end
end
end
end