class HackerSpace < GeographicCommunity
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'HackerSpaceMember'
  has_many :pages, as: :threadable

  store_accessor :websites, :irc_link, :hackerspace_org_link, :wiki_link,
    :mailing_list_link

  attr_accessible :irc_link, :hackerspace_org_link, :wiki_link,
    :mailing_list_link

  has_algolia_index 'pryvate'

  def self.default_access_level
    'anyone'
  end

  def claimed?
    members.with_group_roles('team').any?
  end

  def show_address
    true
  end

  private
    def skip_website_check
      %w(irc_link mailing_list_link)
    end
end