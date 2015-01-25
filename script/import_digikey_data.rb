# full_name,country,state,city,website_link
# csv_text = ""

require 'csv'

csv = CSV.parse(csv_text, headers: true)
spaces=[]
csv.each do |row|
  hash = {}
  row.to_hash.each{|k,v| hash[k] = v.try(:strip) }
  next if HackerSpace.find_by_user_name(hash['user_name'])
  h = HackerSpace.new(hash)
  begin
    spaces << h unless h.save
  rescue
    spaces << h
  end
end



require 'nokogiri'
include ScraperUtils

errors = []

HackerSpace.all.order(:id).each do |space|

# def extract_from_hackerspace_org space, url=nil
  next if space.hackerspace_org_link.present?
  url = 'http://hackerspaces.org/wiki/' + space.name.gsub(' ', '_')
  space.hackerspace_org_link = url

  begin
    data = fetch_page url
  rescue
    errors << space
  end

  doc  = Nokogiri::HTML data

  labels = {
    'Snail mail' => :address,
    'E-mail' => :email,
    'Facebook' => :facebook_link,
    'IRC' => :irc_link,
    'Wiki' => :wiki_link,
    'Website' => :website_link,
    'Twitter' => :twitter_link,
    'Mailinglist' => :mailing_list_link,
  }

  doc = doc.at_css('#mw-content-text table')
  next unless doc
  labels.each do |label, attr|
    els = doc.search "[text()*='#{label}']"
    el = els.first

    next unless el

    val = if el.name == 'th'
      el.next_element.text.strip
    else
      el.parent.parent.next_element.text.strip
    end

    if label == 'Snail mail'
      val.gsub! space.country, '' if space.country
      val.gsub! space.state, '' if space.state
      val.gsub! space.city, '' if space.city
      val.gsub! "\n", ' '
      val.strip!
    end

    puts val
    space.send "#{attr}=", val
  end

  if logo = doc.at_css('.image img').try(:[], 'src')
    logo = 'http://hackerspaces.org' + logo
    bigger = logo.gsub('150px', '300px')
    if test_link bigger
      logo = bigger
    elsif !test_link(logo)
      logo = nil
    end
    if logo
      i = Avatar.new
      i.skip_file_check!
      i.remote_file_url = logo
      puts i.remote_file_url
      space.avatar = i
    end
  end

  # space.save
  errors << space unless space.save
  # puts space.errors.inspect
  # break
end

errors = []

HackerSpace.all.order(:id).each do |space|
  begin
    data = fetch_page space.hackerspace_org_link
  rescue
    errors << space
  end

  doc  = Nokogiri::HTML data

  doc = doc.at_css('#mw-content-text table')
  unless doc
    errors << space
    next
  end

  if logo = doc.at_css('.image img').try(:[], 'src')
    logo = 'http://hackerspaces.org' + logo
    bigger = logo.gsub('150px', '300px')
    if test_link bigger
      logo = bigger
    elsif !test_link(logo)
      errors << space
      next
    end
    i = Avatar.new
    i.skip_file_check!
    i.remote_file_url = logo
    puts i.remote_file_url
    # space.avatar = i
    i.attachable = space
    errors << space unless i.save
  end
end

HackerSpace.all.order(:id).each do |space|
  if space.address =~ /of America/ or space.address =~ /,\s*,/
    space.address = space.address.gsub('of America', '').gsub(/,\s*,/, ',').strip
    space.save
  end
end

out="user_name,city,country,full_name,email,latitude,longitude,address,state,twitter_link,facebook_link,wiki_link,website_link,mailing_list_link,hackerspace_org_link,irc_link\r\n"
HackerSpace.all.each do |space|
  out << "\"#{space.user_name}\","
  out << "\"#{space.city}\","
  out << "\"#{space.country}\","
  out << "\"#{space.full_name}\","
  out << "\"#{space.email}\","
  out << "\"#{space.latitude}\","
  out << "\"#{space.longitude}\","
  out << "\"#{space.address}\","
  out << "\"#{space.state}\","
  out << "\"#{space.twitter_link}\","
  out << "\"#{space.facebook_link}\","
  out << "\"#{space.wiki_link}\","
  out << "\"#{space.website_link}\","
  out << "\"#{space.mailing_list_link}\","
  out << "\"#{space.hackerspace_org_link}\","
  out << "\"#{space.irc_link}\"\r\n"
end
puts out