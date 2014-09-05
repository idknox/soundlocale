class EventsMailer < ActionMailer::Base
  default from: "admin@sound-locale.com"

  def ticketfly_pull(event_count)
    @event_count = event_count
    mail(to: 'knoxid@gmail.com', subject: 'Ticketfly Event Pull')
  end
end