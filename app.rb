require 'sinatra'
require 'twitter'
require 'tzinfo'
require 'sinatra-logentries'
require_relative 'lib/twitter_integration'
require_relative 'helpers/view_helper'

configure { Sinatra::Logentries.token = ENV['LOGENTRIES_TOKEN'] }

logger.info("I'm a Lumberjack and I'm OK")

get '/' do
  twitter = TwitterIntegration.new
  user = ENV['TWITTER_USERNAME']
  options = {:count => 100, :include_rts => true, :exclude_replies => true}

  erb :'home.html', :locals => {:tweets => twitter.client.user_timeline(user, options), :helper => ViewHelper}
end