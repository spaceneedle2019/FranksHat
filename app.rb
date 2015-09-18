require 'sinatra'
require 'twitter'
require_relative 'lib/twitter_integration'
require_relative 'helpers/view_helper'

get '/' do
		'Hello, you!'
end

get '/twitter' do
	twitter = TwitterIntegration.new
	user = ENV['TWITTER_USERNAME']
	options = {:count => 50, :include_rts => true, :exclude_replies => true}

	erb :'twitter.html', :locals => { :tweets => twitter.client.user_timeline(user, options), :helper => ViewHelper }
end