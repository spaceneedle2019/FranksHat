module ViewHelper
  class << self
    URL_REGEX = /\s((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?)/
    HASHMARK = '#'
    AT_SIGN = '@'
    POINT = '.'
    COMMA = ','

    def parse_insta_for_hashtags(text)
      text_array = text.split(' ')
      text_array.map! do |word|
        if word.include?(HASHMARK)
          if word.end_with?(POINT)
            word.delete!(POINT)
            "#{instagram_url_for(word)}#{POINT}"
          elsif word.end_with?(COMMA)
            word.delete!(COMMA)
            "#{instagram_url_for(word)}#{COMMA}"
          else
            instagram_url_for(word)
          end
        else
          word
        end
      end
      text_array.join(' ')
    end

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

    def format(datetime)
      format = '%d.%m.%Y, %H:%M Uhr'
      datetime.strftime(format)
    end

    private

    def collect_hashtags(tweet)
      tweet.hashtags.collect { |key| "#{HASHMARK}#{key.text}" unless key.text == 'fb' }.compact
    end

    def collect_short_urls(tweet)
      tweet.urls.collect { |url| [url.url, url.display_url] } if tweet.urls.respond_to?(:each)
    end

    def collect_user_mentions(tweet)
      tweet.user_mentions.collect { |user_mention| "#{AT_SIGN}#{user_mention.screen_name}" } if tweet.user_mentions.respond_to?(:each)
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
              if entity.start_with?(AT_SIGN)
                "<a href='https://twitter.com/#{entity.delete(AT_SIGN)}'>#{entity}</a>"
              else
                "<a href='https://twitter.com/hashtag/#{entity.delete(HASHMARK)}'>#{entity}</a>"
              end
            end
      end
      replace_hash.each do |key, value|
        key.is_a?(Array) ? tweet_text.sub!(key[0], value) : tweet_text.sub!(key, value)
      end
      return tweet_text
    end

    def instagram_url_for(tag)
      "<a href='https://www.instagram.com/explore/tags/#{tag.delete(HASHMARK)}/'>#{tag}</a>"
    end
  end
end