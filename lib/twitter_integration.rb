class TwitterIntegration
  attr_reader :client

  def initialize
    @client = authenticate
  end

  def user_name
    ENV['TWITTER_USERNAME']
  end

  def options
    {:count => 100, :include_rts => false, :exclude_replies => true}
  end

  private

  def authenticate
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
end
