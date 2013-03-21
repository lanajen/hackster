class Publication < ActiveRecord::Base
  belongs_to :user

  validates :title, presence: true

  attr_accessible :abstract, :coauthors, :link, :journal, :published_on, :title

  before_validation :ensure_link_protocol

  private
    def ensure_link_protocol
      return unless link_changed?
      if link.blank?
        self.link = nil
        return
      end
      self.link = 'http://' + link unless link =~ /^http/
    end
end
