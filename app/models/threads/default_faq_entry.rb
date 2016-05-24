class DefaultFaqEntry < Post
  DEFAULT_ENTRIES_CONF = "#{Rails.root}/config/contest_faq.yml"

  def self.populate_challenge_defaults challenge_id
    default_entries.each do |sid, attributes|
      entry = new
      entry.slug = sid
      entry.title = attributes['q']
      entry.body = attributes['a']
      entry.threadable_id = challenge_id
      entry.threadable_type = 'Challenge'
      entry.user_id = 0
      entry.pryvate = false
      entry.save
    end
  end

  def self.default_entries
    @default_entries ||= YAML.load(File.new(DEFAULT_ENTRIES_CONF).read)
  end

  def condition
    default_attributes['condition']
  end

  def default_attributes
    self.class.default_entries[slug.to_s]
  end
end