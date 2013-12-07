class PressArticle < Tableless
  belongs_to :widget
  # validates :link, presence: true, format: /(?:https?:\/\/)?(?:[\w]+\.)(?:\.?[\w]{2,})+/
  # before_validation :ensure_website_protocol

  column :date, :date
  column :link, :string
  column :publication, :string
  column :title, :string
  column :widget_id, :integer

  private
    # def ensure_website_protocol
    #   return unless link.present?
    #   self.link = 'http://' + link unless link =~ /^http/
    # end
end