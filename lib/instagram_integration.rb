require 'net/http'
require 'uri'
require 'nokogiri'

class InstagramIntegration
  def media
    entry_point(response_object).map do |edge|
      item = edge.node
      OpenStruct.new(
          created_at: DateTime.strptime(item.taken_at_timestamp.to_s, '%s'),
          text: item.edge_media_to_caption.edges[0].node.text,
          image_link: image_link(item.shortcode, item.thumbnail_resources[2].src)
      )
    end
  end

  private

  def response_object
    response = Net::HTTP.get_response(url)
    if response.code.to_i == 200
      page = Nokogiri::HTML(response.body)
      data_string = page.css('body script')[0].text.gsub('window._sharedData = ', '').chop
      JSON.parse(data_string, object_class: OpenStruct)
    end
  end

  def entry_point(data)
    data.entry_data['ProfilePage'][0].graphql.user.edge_owner_to_timeline_media.edges
  end

  def url
    URI.parse("https://www.instagram.com/#{ENV['INSTAGRAM_USERNAME']}/")
  end

  def image_link(code, source)
    "<a href='https://www.instagram.com/p/#{code}/'><img alt='#{code}'src='#{source}'></a>"
  end
end
