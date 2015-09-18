module ViewHelper
  class << self
    def collect_hashtags(tweet)
      tweet.hashtags.collect { |key| "##{key.text}" }
    end

    def collect_short_urls(tweet)
      tweet.urls.collect { |url| [url.url, url.display_url] } if tweet.urls.respond_to?(:each)
    end

    def generate_link(entities, tweet_text)
      replace_hash = {}
      entities.each do |entity|
        replace_hash[entity] =
            if entity[0].is_a?(Addressable::URI)
              "<a href='#{entity[0]}'>http://#{entity[1]}</a>"
            else
              "<a href='https://twitter.com/hashtag/#{entity.delete('#')}'>#{entity}</a>"
            end
      end
      replace_hash.each do |key, value|
        key.is_a?(Array) ? tweet_text.sub!(key[0], value) : tweet_text.sub!(key, value)
      end
      return tweet_text
    end
  end
end