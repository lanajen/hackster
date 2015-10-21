def find_entity_by_url url
  els = url.split('/').select{|v| v.present? }
  entity = if els.size == 2
    project = nil
    if hid = url.match(/-?([a-f0-9]{6})\Z/)
      if project = BaseArticle.find_by_hid(hid[1])
        project
      else
        slug = SlugHistory.where(value: els.join('/')).first
        project = slug.sluggable if slug
      end
    else
      slug = SlugHistory.where(value: els.join('/')).first
      project = slug.sluggable if slug
    end
    project
  elsif els.size == 1
    User.find_by_user_name(els[0]) || Platform.find_by_user_name(els[0])
  else
    BaseArticle.find_by_id els[3]
  end
  entity
rescue => e
  url
end

require 'csv'

first_date = '2015-08-22'.to_time
range = Time.now - first_date
errors = []

csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  url = row[0]
  count = row[1].to_i
  puts "Loading #{url}"
  date = first_date
  if entity = find_entity_by_url(url) and !entity.kind_of?(String)
    interval = range / count
    count.times do
      date += interval
      # entity.impressions.create session_hash: SecureRandom.hex(10), message: "Manually added because missing - 10/16"
      ImpressionistQueue.perform_async 'count', { session_hash: SecureRandom.hex(16) }, nil, nil, nil, entity.id, entity.class.name, "Manually added because missing - 10/16"
    end
  else
    errors << row
  end
end