module ViewHelper
  class << self
    URL_REGEX = /\s((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/

    def parse(tweet)
      user_mentions = collect_user_mentions(tweet)
      hashtags = collect_hashtags(tweet)
      urls = collect_short_urls(tweet)
      tweet_text = tweet.text.dup
      generate_link(hashtags, tweet_text) unless hashtags.count == 0
      generate_link(user_mentions, tweet_text) unless user_mentions.count == 0
      generate_link(urls, tweet_text) unless urls.count == 0
      generate_link_for_unmatched_urls(tweet_text)
      remove_fb_hashtag_from(tweet_text)
    end

    def collect_hashtags(tweet)
      tweet.hashtags.collect { |key| "##{key.text}" unless key.text == 'fb' }.compact
    end

    def collect_short_urls(tweet)
      tweet.urls.collect { |url| [url.url, url.display_url] } if tweet.urls.respond_to?(:each)
    end

    def collect_user_mentions(tweet)
      tweet.user_mentions.collect { |user_mention| "@#{user_mention.screen_name}" } if tweet.user_mentions.respond_to?(:each)
    end

    def remove_fb_hashtag_from(tweet_text)
      tweet_text.include?('#fb') ? tweet_text.gsub!(/#fb/, '').strip : tweet_text
    end

    def generate_link_for_unmatched_urls(tweet_text)
      tweet_text.match(URL_REGEX) ? tweet_text.gsub!(URL_REGEX) { |m| " <a href='#{m.lstrip}'>#{m.lstrip}</a>" } : tweet_text
    end

    def generate_link(entities, tweet_text)
      replace_hash = {}
      entities.each do |entity|
        replace_hash[entity] =
            if entity[0].is_a?(Addressable::URI)
              "<a href='#{entity[0]}'>http://#{entity[1]}</a>"
            else
              if entity.start_with?('@')
                "<a href='https://twitter.com/#{entity.delete('@')}'>#{entity}</a>"
              else
                "<a href='https://twitter.com/hashtag/#{entity.delete('#')}'>#{entity}</a>"
              end
            end
      end
      replace_hash.each do |key, value|
        key.is_a?(Array) ? tweet_text.sub!(key[0], value) : tweet_text.sub!(key, value)
      end
      return tweet_text
    end

    def format(timestamp)
      format = '%d.%m.%Y, %H:%M Uhr'
      timezone = TZInfo::Timezone.get('Europe/Berlin')
      timezone.utc_to_local(timestamp.to_datetime).strftime(format)
    end
  end
end