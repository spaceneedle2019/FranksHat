require 'sinatra'
require 'twitter'
require 'tzinfo'
require 'sinatra-logentries'
require 'tilt/erb'
require_relative 'lib/twitter_integration'
require_relative 'lib/instagram_integration'
require_relative 'views/base'

configure { Sinatra::Logentries.token = ENV['LOGENTRIES_TOKEN'] }

class App < Sinatra::Base
  DEFAULT_LAYOUT = :'templates/layouts/default.html'.freeze

  if App.development?
    require 'dotenv'
    Dotenv.load('.env')
  end

  get '/' do
    erb :'templates/home.html', layout: DEFAULT_LAYOUT,
        locals: {timeline: build_timeline, base: Views::Base, instagram: Views::Instagram, twitter: Views::Twitter}
  end

  get '/:things' do
    erb :'templates/not_found.html', layout: DEFAULT_LAYOUT, locals: {things: params[:things]}
  end

  not_found do
    erb :'templates/not_found.html', layout: DEFAULT_LAYOUT
  end

  error 400..511 do
    erb :'templates/error.html', layout: DEFAULT_LAYOUT, locals: {status: response.status}
  end

  helpers do
    def build_timeline
      twitter = TwitterIntegration.new
      instagram = InstagramIntegration.new
      timeline = merge_timelines(twitter.client.user_timeline(twitter.user_name, twitter.options), instagram.media)
      remove_instagram_duplicates!(timeline)
    end

    def merge_timelines(twitter, instagram)
      timeline = twitter.concat(instagram)
      timeline.map! { |entry| [convert(entry.created_at), entry] }.sort! {|a, b|  b[0] <=> a[0] }
    end

    def convert(timestamp)
      timezone = TZInfo::Timezone.get('Europe/Berlin')
      timezone.utc_to_local(timestamp.to_datetime)
    end

    def remove_instagram_duplicates!(timeline)
      timeline.each_with_index do |(_, entry), index|
        timeline.delete_at(index) if entry.is_a?(Twitter::Tweet) && entry.source.include?('Instagram')
      end
    end
  end
end
