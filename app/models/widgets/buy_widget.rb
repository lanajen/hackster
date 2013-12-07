class BuyWidget < Widget
  define_attributes [:link]
  before_save :ensure_website_protocol

  def self.model_name
    Widget.model_name
  end

  private
    def ensure_website_protocol
      return unless link.present?
      self.link = 'http://' + link unless link =~ /^http/
    end
end
