require_relative '../views/instagram'
require_relative '../views/twitter'

module Views
  URL_REGEX = /\s((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?)/.freeze
  HASHMARK = '#'.freeze
  AT_SIGN = '@'.freeze
  POINT = '.'.freeze
  COMMA = ','.freeze

  module Base
    def self.format(datetime)
      format = '%d.%m.%Y, %H:%M Uhr'
      datetime.strftime(format)
    end
  end
end