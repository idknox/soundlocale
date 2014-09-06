require "open-uri"
require "json"
require "time"
require "net/http"

class TicketflyEvents

  def self.all
    new.all
  end

  def all
    events = all_event_pages
    venue_names = Venue.all.to_a.map { |venue| venue.name }
    events.map { |event| rename_columns(event) if event_venue_exists?(venue_names, event) }
  end

  private

  def get_url
    "http://www.ticketfly.com/api/events/list.json?orgId=1&" +
      "maxResults=200&city=Denver" +
      "&fromDate=#{Date.today.strftime("%Y-%m-%d")}" +
      "&fields=id,name,venue.name,headlinersName,startDate," +
      "ticketPurchaseUrl,ticketPrice,urlTwitter"
  end

  def all_event_pages
    url = get_url
    page_count = get_page_count(url)
    get_all_events(url, page_count)
  end

  def get_page_count(url)
    file = open(url) { |f| f.read }
    JSON.parse(file)["totalPages"]
  end

  def get_all_events(url, page_count)
    events = []
    (1..page_count).each do |page|
      file = open(url+"&pageNum=#{page}") { |f| f.read }
      events += JSON.parse(file)["events"]
    end
    events
  end

  def event_venue_exists?(venues, event)
    venues.include?(event["venue"]["name"])
  end

  def rename_columns(event)
    {
      :name => event["name"],
      :venue_id => Venue.find_by(:name => event["venue"]["name"]).id,
      :venue_name => event["venue"]["name"],
      :vendor_id => event["id"],
      :headliner => event["headlinersName"],
      :date => Date.parse(event["startDate"]).strftime("%Y-%m-%d"),
      :time => Time.parse(event["startDate"]).strftime("%H:%M:%S"),
      :tickets => event["ticketPurchaseUrl"],
      :url => event["ticketPurchaseUrl"],
      :twitter => event["urlTwitter"],
      :price => event["ticketPrice"]
    }
  end
end