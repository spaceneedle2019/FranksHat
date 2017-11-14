module Views
  module Instagram
    class << self
      def parse(message)
        message_array = message.split(' ')
        message_array.map! do |word|
          if word.include?(Views::HASHMARK)
            populate_tag_url(word)
          elsif word.start_with?(Views::AT_SIGN)
            "<a href='https://www.instagram.com/#{word.delete(Views::AT_SIGN)}'>#{word}</a>"
          else
            word
          end
        end
        message_array.join(' ')
      end

      private

      def populate_tag_url(word)
        if word.end_with?(Views::POINT)
          "#{url_for(word.delete(Views::POINT))}#{Views::POINT}"
        elsif word.end_with?(Views::COMMA)
          "#{url_for(word.delete(Views::COMMA))}#{Views::COMMA}"
        else
          url_for(word)
        end
      end

      def url_for(tag)
        "<a href='https://www.instagram.com/explore/tags/#{tag.delete(Views::HASHMARK)}/'>#{tag}</a>"
      end
    end
  end
end
