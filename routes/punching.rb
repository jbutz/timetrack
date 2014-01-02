module Sinatra
module TimeTrack
module Routing
	module Punching
		def self.registered(app)
			app.post '/punch/:type', :auth => '' do
				if !session[:authenticated]
					erb :fail
					return
				end

				# Setup PunchTime
				timestamp = PunchTime.new settings.timezoneName

				email = session[:email]
				timestamp.set_time params[:timestamp]

				if params[:type] == "in"
					t = Punch.new({
						in: timestamp.to_db,
						email: email
					})
				elsif params[:type] == "out"
					t = Punch.where(out: nil).first
					t.out = timestamp.to_db
				else
					"WTF are you trying to pull?"
				end
				if t.save
					flash[:notice] = "Punched at #{timestamp.to_display}"
					redirect '/'
				else
					"Error saving punch"
				end
			end

			app.get '/punch/:type', :auth => '' do
				if !session[:authenticated]
					erb :fail
					return
				end
				email = session[:email]
				timestamp = PunchTime.new settings.timezoneName

				if params[:type] == "in"
					t = Punch.new({
						in: timestamp.to_db,
						email: email
					})
				elsif params[:type] == "out"
					t = Punch.where(out: nil).first
					t.out = timestamp.to_db
				else
					"WTF are you trying to pull?"
				end
				if t.save
					flash[:notice] = "Punched at #{timestamp.to_display}"
					redirect '/'
				else
					"Error saving punch"
				end
			end
		end
	end
end
end
end