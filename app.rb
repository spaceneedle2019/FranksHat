require 'sinatra'
require 'twitter'
require 'tzinfo'
require 'sinatra-logentries'
require 'tilt/erb'
require_relative 'helpers/application_helper'
require_relative 'helpers/view_helper'
require_relative 'lib/twitter_integration'
require_relative 'lib/instagram_integration'

configure { Sinatra::Logentries.token = ENV['LOGENTRIES_TOKEN'] }

class App < Sinatra::Base
  if App.development?
    require 'dotenv'
    Dotenv.load('.env')
  end

  before do
    DEFAULT_LAYOUT = :'layouts/default.html'.freeze
  end

  get '/' do
    erb :'home.html', layout: DEFAULT_LAYOUT, locals: {timeline: build_timeline, helper: ViewHelper}
  end

  get '/:things' do
    erb :'not_found.html', layout: DEFAULT_LAYOUT, locals: {things: params[:things]}
  end

  not_found do
    erb :'not_found.html', layout: DEFAULT_LAYOUT
  end

  error 400..511 do
    erb :'error.html', layout: DEFAULT_LAYOUT, locals: {status: response.status}
  end

  helpers do
    def build_timeline
      twitter = TwitterIntegration.new
      instagram = InstagramIntegration.new
      timeline =
          ApplicationHelper.merge_timelines(
              twitter.client.user_timeline(twitter.user_name, twitter.options),
              instagram.media
          )
      ApplicationHelper.remove_instagram_duplicates!(timeline)
    end
  end
end

