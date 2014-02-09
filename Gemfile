source "http://rubygems.org"
ruby '1.9.3'

# Authentication
gem 'oauth2'

# Framework
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-flash'

# Database
gem 'mongoid'
gem 'bson_ext'

# Time
gem 'chronic'
gem 'tzinfo'

group :development, :test do
	gem 'rake'

	# Testing
    gem 'rspec'
    gem 'rack-test', :require => "rack/test"

    # Debugging
    gem 'pry'
    gem 'pry-nav'
end

group :production do
	# Web server
	gem 'puma'
end