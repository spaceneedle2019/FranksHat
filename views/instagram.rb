module Views
  module Instagram
    class << self
      def parse(message)
        message_array = message.split(' ')
        message_array.map! do |word|
          next populate_tag_url(word) if word.include?(Views::HASHMARK)
          next account_url_for(word) if word.start_with?(Views::AT_SIGN)
          word
        end
        message_array.join(' ')
      end

      private

      def populate_tag_url(word)
        return "#{tag_url_for(word.delete(Views::POINT))}#{Views::POINT}" if word.end_with?(Views::POINT)
        return "#{tag_url_for(word.delete(Views::COMMA))}#{Views::COMMA}" if word.end_with?(Views::COMMA)
        tag_url_for(word)
      end

      def tag_url_for(word)
        "<a href='https://www.instagram.com/explore/tags/#{word.delete(Views::HASHMARK)}/'>#{word}</a>"
      end

      def account_url_for(word)
        "<a href='https://www.instagram.com/#{word.delete(Views::AT_SIGN)}'>#{word}</a>"
      end
    end
  end
end
