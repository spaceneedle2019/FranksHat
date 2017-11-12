require 'net/http'
require 'uri'

class InstagramIntegration
  def media
    media_object.nodes.map do |item|
      code = item.code
      source = item.thumbnail_resources[2].src
      created_at = DateTime.strptime(item.date.to_s, '%s')
      image_link = "<a href='https://www.instagram.com/p/#{code}/'><img alt='#{code}'src='#{source}'></a>"
      OpenStruct.new(:created_at => created_at, :text => item.caption, :image_link => image_link)
    end
  end

  private

  def media_object
    response = Net::HTTP.get_response(url)
    JSON.parse(response.body, object_class: OpenStruct).user.media if response.code.to_i == 200
  end

  def user_name
    ENV['INSTAGRAM_USERNAME']
  end

  def url
    URI.parse("https://www.instagram.com/#{user_name}/?__a=1")
  end

end