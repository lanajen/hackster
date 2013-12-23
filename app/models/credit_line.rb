class CreditLine < Tableless
  belongs_to :widget
  validates :link, format: { with: /(?:https?:\/\/)?(?:[\w]+\.)(?:\.?[\w]{2,})+/, message: 'is not a valid URL' }, allow_blank: true
  before_validation :ensure_website_protocol
  attr_accessible :link, :name, :work, :widget_id

  column :link, :string
  column :name, :string
  column :work, :string
  column :widget_id, :integer

  private
    def ensure_website_protocol
      return unless link.present?
      self.link = 'http://' + link unless link =~ /^http/
    end
end