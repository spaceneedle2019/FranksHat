module ApplicationHelper
  class << self
    def merge_timelines(twitter, instagram)
      timeline = twitter.concat(instagram)
      timeline.map! { |entry| [convert(entry.created_at), entry] }.sort! {|a, b|  b[0] <=> a[0] }
    end

    def remove_instagram_duplicates!(timeline)
      timeline.each_with_index do |(_, entry), index|
        timeline.delete_at(index) if entry.is_a?(Twitter::Tweet) && entry.source.include?('Instagram')
      end
    end

    private

    def convert(timestamp)
      timezone = TZInfo::Timezone.get('Europe/Berlin')
      timezone.utc_to_local(timestamp.to_datetime)
    end
  end
end