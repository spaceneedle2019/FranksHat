require 'net/http'
require 'uri'

class InstagramIntegration
  def media
    media = []
    media_object = populate_media_object
    media_object.items.each do |item|
      code = item.code
      image_url = item.images.low_resolution.url
      image_link = "<a href='https://www.instagram.com/p/#{code}/'><img alt='#{code}'src='#{image_url}'></a>"
      media << OpenStruct.new(
          :created_at => DateTime.strptime(item.caption.created_time, '%s'),
          :text => item.caption.text,
          :image_link => image_link
      )
    end
    media
  end

  private

  def populate_media_object
    response = Net::HTTP.get_response(url)
    if response.code.to_i == 200
      json = JSON.parse(response.body, object_class: OpenStruct)
      json if json.status == 'ok'
    end
  end

  def user_name
    ENV['INSTAGRAM_USERNAME']
  end

  def url
    URI.parse("https://www.instagram.com/#{user_name}/media/")
  end

end