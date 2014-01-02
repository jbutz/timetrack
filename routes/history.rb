module Sinatra
module TimeTrack
module Routing
	module History
		def self.registered(app)
	    	app.get '/history/details', :auth => '' do
				@punches = Punch.order_by(:in.desc, :out.desc)
				erb :detail
			end

			app.get '/history', :auth => '' do
				map = %Q{
				  function() {
				  	if(this.out)
				    	emit(this.in.toDateString(), this.out - this.in);
				    else
				    {
				    	var d = new Date();
				    	emit(this.in.toDateString(), d - this.in);
				    }
				  }
				}

				reduce = %Q{
				  function(key, values) {
				    var result = 0;
				    values.forEach(function(value) {
				      result += value;
				    });
				    return result;
				  }
				}

				@punches = Punch.map_reduce(map, reduce).out(inline: true).sort_by do |x|
					Chronic.parse(x['_id'])
				end
				@punches = @punches.reverse!
				erb :history
			end
		end
	end
end
end
end