require "date"

class TflyTable

  def initialize(db)
    @db = db
  end

  def all
    @db.sql(
      "SELECT * FROM events WHERE date >= '#{Date.today.strftime("%Y-%m-%d")}'"
    )
  end

  def get_ids
    @db.sql(
      "SELECT tf_id FROM events"
    )
  end

  def create(events)
    events.each do |event|
      event["name"].gsub!("'", "")
      event["venue"]["name"].gsub!("'", "")
      event["headlinersName"].gsub!("'", "")
      unless event_exists(event["id"])
        @db.sql(
          "INSERT INTO events (tf_id, name, venue, headliner, date, tickets, price, url, twitter, image) VALUES " +
            "(#{event["id"]}, '#{event["name"]}', '#{event["venue"]["name"]}', '#{event["headlinersName"]}', " +
            "'#{Date.parse(event["startDate"]).strftime("%m-%d-%Y")}', " +
            "'#{event["ticketPurchaseUrl"]}', '#{event["ticketPrice"]}', " +
            "'#{event["urlOfficialWebsite"]}', '#{event["urlTwitter"]}', '#{event["image"]["xlarge"]["path"]}')"
        )
      end
    end
  end

  def find(id)
    @db.sql(
      "SELECT * FROM events WHERE id=#{id}"
    )[0]
  end

  def find_by_venue(venue)
    @db.sql(
      "SELECT * FROM events WHERE venue = '#{venue}' and " +
        "date >= '#{Date.today.strftime("%Y-%m-%d")}'"
    )
  end

  def find_by_date(date)
    @db.sql(
      "SELECT * FROM events WHERE date='#{Date.parse(date).strftime("%m-%d-%Y")}'"
    )
  end

  def update(event)
    @db.sql(
      "UPDATE events set name='#{event[:name]}', venue='#{event[:venue]}', " +
        "headliner='#{event[:headliner]}', price='#{event[:price]}', " +
        "date='#{Date.parse(event[:date]).strftime("%m-%d-%Y")}', " +
        "tickets='#{event[:tickets]}' WHERE id=#{event[:id]}"
    )
  end

  def delete(id)
    @db.sql(
      "DELETE FROM events WHERE id=#{id}"
    )
  end

  def del_all
    @db.sql(
      "DELETE FROM events"
    )
  end

  def event_exists(id)
    @db.sql(
      "SELECT * FROM events where tf_id=#{id}"
    ) != []
  end

end