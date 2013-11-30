require 'feedzirra'

feed = Feedzirra::Feed.fetch_and_parse("http://feeds2.feedburner.com/hackaday/LgoM")

header = "url,title,last_modified,categories,authors,links,body\r\n"
out = header

feed.entries.each do |entry|
  authors = entry.content.scan(/\[([^\s]+)\]/).flatten.uniq.join("\n")
  doc = Nokogiri::HTML entry.content
  links = doc.css('a').reduce({}) do |memo, a|
    memo[a.children.text] = a.attributes['href'].try(:value)
    memo
  end.reject{|k,v| v.nil? or v.match(/hackaday[\.]?com/) }.map{|k,v| "#{k}: #{v}"}.join("\n")
  categories = entry.categories.join("\n")

  out << "\"#{entry.url}\","
  out << "\"#{entry.title}\","
  out << "\"#{entry.last_modified}\","
  out << "\"#{categories}\","
  out << "\"#{authors}\","
  out << "\"#{links}\","
  out << "\"#{entry.content}\"\r\n"
end

file_name = File.join(Rails.root, 'public', "hackaday_feed_#{Time.now.to_i}.csv")

File.open(file_name, 'w+') do |file|
  file.syswrite out
end