module Octopus
  def self.shards_in(group=nil)
    config[Rails.env].try(:[], group.to_s).try(:keys)
  end
  def self.followers
    shards_in(:followers)
  end
  class << self
    alias_method :followers_in, :shards_in
    alias_method :slaves_in, :shards_in
  end
end
if Octopus.enabled?
  count = case (Octopus.config[Rails.env].values[0].values[0] rescue nil)
  when Hash
    Octopus.config[Rails.env].map{|group, configs| configs.count}.sum rescue 0
  else
    Octopus.config[Rails.env].keys.count rescue 0
  end

  puts "=> #{count} #{'database'.pluralize(count)} enabled as read-only #{'slave'.pluralize(count)}"
  if Octopus.followers.count == count
    Octopus.followers.each{ |f| puts "  * #{f.split('_')[0].upcase} #{f.split('_')[1]}" }
  end
end