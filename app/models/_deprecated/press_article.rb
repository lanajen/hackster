class PressArticle < Tableless
  belongs_to :widget
  validates :link, format: { with: /(?:https?:\/\/)?(?:[\w]+\.)(?:\.?[\w]{2,})+/, message: 'is not a valid URL' }, allow_blank: true
  before_validation :ensure_website_protocol
  attr_accessible :date, :publication, :title, :widget_id, :link

  column :date, :date
  column :link, :string
  column :publication, :string
  column :title, :string
  column :widget_id, :integer

  private
    def ensure_website_protocol
      return unless link.present?
      self.link = 'http://' + link unless link =~ /^http/
    end
end