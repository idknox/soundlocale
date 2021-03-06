require "open-uri"

class Songkick

  def self.events
    new.all
  end

  def all
    events = get_events
    venue_names = Venue.all.to_a.map { |venue| venue.name }

    events.map do |event|
      if event_venue_exists?(venue_names, event)
        rename_columns(event)
      end
    end
  end

  private

  def get_url
    "http://api.songkick.com/api/3.0/events.json?apikey=#{ENV['SONGKICK_KEY']}" +
      "&location=sk:6404&per_page=100"
  end

  def get_events
    url = get_url
    total_pages = number_of_pages(url)
    get_all_pages(url, total_pages)
  end

  def number_of_pages(url)
    file = open(url) { |f| f.read }
    (JSON.parse(file)["resultsPage"]["totalEntries"] / JSON.parse(file)["resultsPage"]["perPage"])
  end

  def get_all_pages(url, total_pages)
    events = []
    (1..total_pages).each do |page|
      file = open(url+"&page=#{page}") { |f| f.read }
      events += JSON.parse(file)["resultsPage"]["results"]["event"]
    end
    events
  end

  def event_venue_exists?(venues, event)
    venues.include?(event["venue"]["displayName"])
  end

  def rename_columns(event)
    headliner = "NA"
    headliner = event["series"]["displayName"] if event["series"]
    headliner = event["performance"][0]["artist"]["displayName"] if event["performance"][0]

    {
      name: headliner,
      venue_id: Venue.find_by(name: event["venue"]["displayName"]).id,
      venue_name: event["venue"]["displayName"],
      vendor_id: event["id"].to_i,
      headliner: headliner,
      date: Date.parse(event["start"]["date"]),
      time: ensured_time(event),
      tickets: "",
      url: event["uri"],
      twitter: "",
      price: "",
      soundcloud_url: SoundcloudService.new.get_first_track(headliner)
    }
  end

  def ensured_time(event)
    event["start"]["time"] ? Time.parse(event["start"]["time"]) : "TBD"
  end
end