class EmbedWidget < Widget
  define_attributes [:comment, :url]
  validates :url, presence: true
  validate :repository_is_recognized

  def self.model_name
    Widget.model_name
  end

  def embed
    @embed ||= Embed.new url: url
  end

  def identifier
    'embed_widget'
  end

  def name
    read_attribute(:name).presence || embed.try(:provider_name).try(:to_s).try(:capitalize) || 'Untitled'
  end

  private
    def repository_is_recognized
      return unless url.present?

      embed = Embed.new url: url
      errors.add :url, "is not recognized. Please insert the HTTP link of the repository." unless valid_repo?
    end

    def valid_repo?
      raise 'Valid repos not defined. Please add method `valid_repo?` to your widget model.'
    end
end