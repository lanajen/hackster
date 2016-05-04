module EventHelper
  def google_calendar_link event
    url = 'http://www.google.com/calendar/event?action=TEMPLATE&'
    parameters = {}
    parameters[:dates] = [event.cal_start_date, event.cal_end_date].join('/')
    parameters[:text] = event.name
    parameters[:location] = event.full_street_address
    parameters[:details] = 'More info on: ' + group_url(event) + "\n\n" + event.about if event.about
    url << parameters.map{|k,v| "#{k}=#{CGI.escape(v)}" }.join('&')
    url
  end

  def map_link event
    "https://www.google.com/maps/search/#{CGI.escape(@event.full_street_address)}"
  end

  def yahoo_calendar_link event
    url = 'http://calendar.yahoo.com/?v=60&TYPE=21&'
    parameters = {}
    parameters['ST'] = event.cal_start_date
    parameters['ET'] = event.cal_end_date
    parameters['TITLE'] = event.name
    parameters['in_st'] = event.address
    parameters['in_csz'] = [event.city, event.state].select{|v| v.present? }.join(', ')
    parameters['DESC'] = 'More info on: ' + group_url(event) + "\n\n" + event.about if event.about
    url << parameters.map{|k,v| "#{k}=#{CGI.escape(v)}" }.join('&')
    url
  end
end