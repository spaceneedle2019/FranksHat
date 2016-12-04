require 'sinatra'
require 'twitter'
require 'tzinfo'
require 'sinatra-logentries'
require 'tilt/erb'
require_relative 'lib/twitter_integration'
require_relative 'lib/instagram_integration'
require_relative 'helpers/view_helper'
require_relative 'helpers/application_helper'

configure { Sinatra::Logentries.token = ENV['LOGENTRIES_TOKEN'] }
DEFAULT_LAYOUT = :'layouts/default.html'

get '/' do
  twitter = TwitterIntegration.new
  instagram = InstagramIntegration.new
  timeline =
      ApplicationHelper.merge_timelines(
          twitter.client.user_timeline(twitter.user_name, twitter.options),
          instagram.media
      )
  ApplicationHelper.remove_instagram_duplicates_from(timeline)
  erb :'home.html', :layout => DEFAULT_LAYOUT, :locals => {:timeline => timeline, :helper => ViewHelper}
end

get '/:things' do
  erb :'not_found.html', :layout => DEFAULT_LAYOUT, :locals => {:things => params[:things]}
end

not_found do
  erb :'not_found.html', :layout => DEFAULT_LAYOUT
end