class IframeSchematicsWidget < Widget
  def self.model_name
    Widget.model_name
  end

  define_attributes [:code, :link]
  attr_accessible :link
  # validates :code, presence: true, if: proc{ |w| w.persisted? }
  validates :link, format: { with: lambda { |w| w.link_regexp }, message: 'is not a valid project URL' }, allow_blank: true
  before_save :generate_iframe_from_link

  def default_label
    'Schematics'
  end

  def identifier
    'iframe_schematics_widget'
  end

  def iframe_template
    raise NoMethodError
  end

  def link_regexp
    raise NoMethodError
  end

  def provider
    raise NoMethodError
  end

  def to_text
    link.present? ? "<h3>#{name}</h3><div contenteditable='false' class='embed-frame' data-type='url' data-url='#{link}' data-caption=''></div>" : ''
  end

  private
    def generate_iframe_from_link
      return unless link.present?
      link.match(link_regexp)
      id = $1.to_s
      title = $2.to_s
      self.code = iframe_template.gsub(/\|title\|/, title).gsub(/\|id\|/, id)
    end
end
