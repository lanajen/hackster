class Announcement < BlogPost
  attr_accessible :published_at, :display_until

  def self.current
    published.where('threads.display_until IS NULL OR threads.display_until > ?', Time.now).first
  end

  def self.published
    where(draft: false).where('threads.published_at IS NULL OR threads.published_at < ?', Time.now)
  end

  def tech
    threadable
  end
end
