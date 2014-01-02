module Sinatra
module TimeTrack
	module Helpers
		def redirect_uri(request)
			uri = URI.parse(request.url)
			uri.path = '/oauth2callback'
			uri.query = nil
			uri.to_s
		end
		def client
			client ||= OAuth2::Client.new(G_API_CLIENT, G_API_SECRET, {
				:site => 'https://accounts.google.com',
				:authorize_url => "/o/oauth2/auth",
				:token_url => "/o/oauth2/token"
			})
		end
	end
end
end