require 'sinatra'
require 'twitter'
require_relative 'lib/twitter_integration'
require_relative 'helpers/view_helper'

get '/' do
  twitter = TwitterIntegration.new
  user = ENV['TWITTER_USERNAME']
  options = {:count => 100, :include_rts => true, :exclude_replies => true}

  erb :'home.html', :locals => {:tweets => twitter.client.user_timeline(user, options), :helper => ViewHelper}
end