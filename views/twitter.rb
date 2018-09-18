module Views
  module Twitter
    BASE_URL = 'https://twitter.com'.freeze

    class << self
      def parse(tweet)
        tweet_text = tweet.text.dup
        hashtags, urls, user_mentions = collect_data(tweet)
        [hashtags, urls, user_mentions].each {|type| generate_link!(tweet_text, type) unless type.count == 0}
        generate_link_for_unmatched_urls!(tweet_text)
      end

      private

      def collect_data(tweet)
        hashtags = tweet.hashtags.collect {|key| "#{Views::HASHMARK}#{key.text}" unless key.text == 'fb'}.compact
        short_urls = tweet.urls.collect {|url| [url.url, url.display_url]} if tweet.urls.respond_to?(:each)
        user_mentions =
            if tweet.user_mentions.respond_to?(:each)
              tweet.user_mentions.collect {|user_mention| "#{Views::AT_SIGN}#{user_mention.screen_name}"}
            end
        return hashtags, short_urls, user_mentions
      end

      def generate_link_for_unmatched_urls!(tweet_text)
        return tweet_text unless tweet_text.match(Views::URL_REGEX)
        tweet_text.gsub!(Views::URL_REGEX) {|m| " <a href='#{m.lstrip}'>#{m.lstrip}</a>"}
      end

      def generate_link!(tweet_text, entities)
        hash =
            entities.each_with_object({}) do |entity, hash|
              hash[entity] =
                  if entity[0].is_a?(Addressable::URI)
                    external_url_for(entity)
                  else
                    entity.start_with?(Views::AT_SIGN) ? account_url_for(entity) : hashtag_url_for(entity)
                  end
            end
        search_and_replace!(hash, tweet_text)
        tweet_text
      end

      def search_and_replace!(hash, tweet_text)
        hash.each do |key, value|
          if key.is_a?(Array)
            tweet_text.sub!(key[0], value)
          else
            tweet_text.sub!(key, value) || tweet_text.sub!(key.downcase, value)
          end
        end
      end

      def account_url_for(entity)
        "<a href='#{BASE_URL}/#{entity.delete(Views::AT_SIGN)}'>#{entity}</a>"
      end

      def hashtag_url_for(entity)
        "<a href='#{BASE_URL}/hashtag/#{entity.delete(Views::HASHMARK)}'>#{entity}</a>"
      end

      def external_url_for(entity)
        "<a href='#{entity[0]}'>http://#{entity[1]}</a>"
      end
    end
  end
end
