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
			client ||= OAuth2::Client.new(ENV['G_API_CLIENT'], ENV['G_API_SECRET'], {
				:site => 'https://accounts.google.com',
				:authorize_url => "/o/oauth2/auth",
				:token_url => "/o/oauth2/token"
			})
		end
		def time_by_day
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

			Punch.map_reduce(map, reduce).out(inline: true).sort_by do |x|
				Chronic.parse(x['_id'])
			end
		end
		def time_by_week
			map = %Q{
			  function() {
			  	var outDate = new Date(this.in);
			  	outDate.setDate(this.in.getDate() - this.in.getDay())
			  	if(this.out)
			    	emit(outDate.toDateString(), this.out - this.in);
			    else
			    {
			    	var d = new Date();
			    	emit(outDate.toDateString(), d - this.in);
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

			Punch.map_reduce(map, reduce).out(inline: true).sort_by do |x|
				Chronic.parse(x['_id'])
			end
		end
	end
end
end