require 'net/http'
require 'uri'

class InstagramIntegration
  def media
    edges_array = response_object.graphql.user.edge_owner_to_timeline_media.edges
    edges_array.map do |edge|
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
    JSON.parse(response.body, object_class: OpenStruct) if response.code.to_i == 200
  end

  def url
    URI.parse("https://www.instagram.com/#{ENV['INSTAGRAM_USERNAME']}/?__a=1")
  end

  def image_link(code, source)
    "<a href='https://www.instagram.com/p/#{code}/'><img alt='#{code}'src='#{source}'></a>"
  end
end
