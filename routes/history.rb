module Sinatra
module TimeTrack
module Routing
	module History
		def self.registered(app)
			app.get '/history', :auth => '' do
				@punches = time_by_day().reverse!
				erb :history
			end

			app.get '/history/graph/week', :auth => '' do
				@output = {
					labels: [],
					datasets: [{
						fillColor: "rgba(220,220,220,0.5)",
						strokeColor: "rgba(220,220,220,1)",
						pointColor: "rgba(220,220,220,1)",
						pointStrokeColor: "#fff",
						data: []
					}]
				}
				time_by_week().reverse.take(10).reverse.each do |x|
					@output[:labels] << x['_id']
					@output[:datasets][0][:data] << (x['value'] / 1000 / 3600).round(2)
				end
				erb :graph_week
			end

			app.get '/history/graph/day', :auth => '' do
				@output = {
					labels: [],
					datasets: [{
						fillColor: "rgba(220,220,220,0.5)",
						strokeColor: "rgba(220,220,220,1)",
						pointColor: "rgba(220,220,220,1)",
						pointStrokeColor: "#fff",
						data: []
					}]
				}
				time_by_day().reverse.take(30).reverse.each do |x|
					@output[:labels] << x['_id']
					@output[:datasets][0][:data] << (x['value'] / 1000 / 3600).round(2)
				end
				erb :graph_day
			end
		end
	end
end
end
end