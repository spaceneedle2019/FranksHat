require_relative '../views/base'

module Views
  module Instagram
    class << self
      def parse(message)
        message_array = message.split(' ')
        message_array.map! do |word|
          if word.include?(Views::HASHMARK)
            if word.end_with?(Views::POINT)
              word.delete!(Views::POINT)
              "#{url_for(word)}#{Views::POINT}"
            elsif word.end_with?(Views::COMMA)
              word.delete!(Views::COMMA)
              "#{url_for(word)}#{Views::COMMA}"
            else
              url_for(word)
            end
          else
            word
          end
        end
        message_array.join(' ')
      end

      private

      def url_for(tag)
        "<a href='https://www.instagram.com/explore/tags/#{tag.delete(Views::HASHMARK)}/'>#{tag}</a>"
      end
    end
  end
end
