require 'sinatra'
require 'sinatra/flash'
require "sinatra/config_file"
require 'mongoid'
require 'json'
require 'oauth2'
require 'chronic'
require './lib/punch_time'

config_file File.dirname(__FILE__) + '/config/config.yml'

class Punch
	include Mongoid::Document

	field :in, type: Time
	field :out, type: Time
	field :email, type: String
end

# enable :sessions

##
# Scopes are space separated strings
SCOPES = [
	'https://www.googleapis.com/auth/userinfo.email'
].join(' ')

unless G_API_CLIENT = ENV['G_API_CLIENT']
	raise "You must specify the G_API_CLIENT env variable"
end

unless G_API_SECRET = ENV['G_API_SECRET']
	raise "You must specify the G_API_SECRET env variable"
end

unless VALID_EMAIL = ENV['VALID_EMAIL']
	raise "You must specify the VALID_EMAIL env variable"
end

def client
	client ||= OAuth2::Client.new(G_API_CLIENT, G_API_SECRET, {
		:site => 'https://accounts.google.com',
		:authorize_url => "/o/oauth2/auth",
		:token_url => "/o/oauth2/token"
	})
end
set(:auth) do |auth|
  condition do
    unless session[:authenticated]
      redirect "/", 303
    end
  end
end
get '/' do
	@authenticated = session[:authenticated]
	@openpunch = Punch.where(out: nil).first
	@now = PunchTime.new( settings.timezoneName ).now.to_display

	response['Cache-Control'] = 'no-cache, no-store, must-revalidate'
	response['Pragma'] = 'no-cache'
	response['Expires'] = '0'
	erb :index
end

get '/history/details', :auth => '' do
	@punches = Punch.order_by(:in.desc, :out.desc)
	erb :detail
end

get '/history', :auth => '' do
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

### EDITING
get '/edit/:id', :auth => '' do
	@punch = Punch.find(params[:id])
	erb :edit
end

post '/edit/:id', :auth => '' do
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

get '/delete/:id', :auth => '' do
	if Punch.find(params[:id]).destroy
		flash[:notice] = "Punch Deleted!"
		redirect '/'
	else
		flash[:notice] = "Punch was not deleted."
		redirect '/edit/' + params[:id]
	end
end

### PUNCHING
post '/punch/:type', :auth => '' do
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

get '/punch/:type', :auth => '' do
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

### AUTHENTICATION

get "/auth" do
	redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri,:scope => SCOPES,:access_type => "online")
end

get '/oauth2callback' do
	access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
	session[:access_token] = access_token.token
	@message = "Successfully authenticated with the server"
	@access_token = session[:access_token]

	# parsed is a handy method on an OAuth2::Response object that will
	# intelligently try and parse the response.body
	response = access_token.get('https://www.googleapis.com/userinfo/email?alt=json')
	session[:email] = response.parsed['data']['email']
	session[:authenticated] = VALID_EMAIL.include? session[:email]

	if session[:authenticated]
		redirect to('/')
	else
		erb :fail
	end
end

def redirect_uri
	uri = URI.parse(request.url)
	uri.path = '/oauth2callback'
	uri.query = nil
	uri.to_s
end