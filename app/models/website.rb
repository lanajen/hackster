class Website < ActiveRecord::Base
  belongs_to :user

  attr_accessible :url
  validates :url, :user_id, presence: true
  before_validation :ensure_protocol

  private
    def ensure_protocol
      self.url = 'http://' + url unless url =~ /^http/
    end
end
