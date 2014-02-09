module Sinatra
module TimeTrack
module Routing
	module Edit
		def self.registered(app)
			app.get '/edit/:id', :auth => '' do
				@punch = Punch.find(params[:id])
				erb :edit
			end

			app.post '/edit/:id', :auth => '' do
				# Setup the PunchTimes
				inTime = PunchTime.new settings.timezoneName
				outTime = PunchTime.new settings.timezoneName

				inTime.set_time params[:in] unless params[:in].nil? || params[:in].empty?
				outTime.set_time params[:out] unless params[:out].nil? || params[:out].empty?


				if !inTime.valid?
					flash[:notice] = "You have to have a time for the punch to start..."
					redirect '/edit/' + params[:id]
				end
				punch = Punch.find(params[:id]).update_attributes(
					in: inTime.to_db,
					out: outTime.to_db
				)
				if punch
					flash[:notice] = "Punch Updated!"
					redirect '/'
				else
					flash[:notice] = "Punch was not updated."
					redirect '/edit/' + params[:id]
				end
			end

			app.get '/delete/:id', :auth => '' do
				if Punch.find(params[:id]).destroy
					flash[:notice] = "Punch Deleted!"
					redirect '/'
				else
					flash[:notice] = "Punch was not deleted."
					redirect '/edit/' + params[:id]
				end
			end

			app.get '/punchlist', :auth => '' do
				@punches = Punch.order_by(:in.desc, :out.desc)
				erb :punchlist
			end
		end
	end
end
end
end