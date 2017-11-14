module Views
  module Twitter
    class << self
      def parse(tweet)
        hashtags, urls, user_mentions = collect_data(tweet)
        tweet_text = tweet.text.dup
        generate_link!(tweet_text, hashtags) unless hashtags.count == 0
        generate_link!(tweet_text, user_mentions) unless user_mentions.count == 0
        generate_link!(tweet_text, urls) unless urls.count == 0
        generate_link_for_unmatched_urls!(tweet_text)
        remove_fb_hashtag!(tweet_text)
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

      def remove_fb_hashtag!(tweet_text)
        tweet_text.include?('#fb') ? tweet_text.gsub!(/#fb/, '').strip : tweet_text
      end

      def generate_link_for_unmatched_urls!(tweet_text)
        if tweet_text.match(Views::URL_REGEX)
          tweet_text.gsub!(Views::URL_REGEX) {|m| " <a href='#{m.lstrip}'>#{m.lstrip}</a>"}
        else
          tweet_text
        end
      end

      def generate_link!(tweet_text, entities)
        hash =
            entities.each_with_object({}) do |entity, hash|
              hash[entity] =
                  if entity[0].is_a?(Addressable::URI)
                    "<a href='#{entity[0]}'>http://#{entity[1]}</a>"
                  else
                    if entity.start_with?(Views::AT_SIGN)
                      "<a href='https://twitter.com/#{entity.delete(Views::AT_SIGN)}'>#{entity}</a>"
                    else
                      "<a href='https://twitter.com/hashtag/#{entity.delete(Views::HASHMARK)}'>#{entity}</a>"
                    end
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
    end
  end
end
