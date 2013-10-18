require 'chronic'
require 'tzinfo'

class PunchTime

	def initialize( tz )
		@tz = TZInfo::Timezone.get(tz)
		# Defaults to nil
		@time = nil

		self
	end

	def now
		@time = Time.now.utc
		self
	end

	def set_time( text_str )
		# We assume they are providing their local time
		@time = @tz.local_to_utc( Chronic.parse(text_str) )

		self
	end

	def valid?
		!!@time == true
	end

	# Consistently display a format
	def to_display
		#@tz.utc_to_local( @time ).strftime("%m/%d/%Y %H:%M")
		@tz.strftime("%m/%d/%Y %H:%M", @time)
	end

	# EVERYTHING in the DB needs to be UTC
	def to_db
		@time
	end
end