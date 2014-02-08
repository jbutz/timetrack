class Punch
	include Mongoid::Document

	field :in, type: Time
	field :out, type: Time
	field :email, type: String
end