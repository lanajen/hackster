class UpverterWidget < Widget
  IFRAME_TEMPLATE = '<iframe title="|title|" width="420" height="315" scrolling="no" frameborder="0" name="|title|"             class="eda_tool" src="http://upverter.com/eda/embed/#designId=|id|,actionId="></iframe>'

  def self.model_name
    Widget.model_name
  end

  define_attributes [:code]
  attr_accessor :link
  attr_accessible :code, :link
  # validates :code, presence: true
  before_save :resize_iframe
  before_save :generate_iframe_from_link

  private
    def generate_iframe_from_link
      return unless link
      link.match(/upverter\.com\/[^\/]+\/([a-z0-9]+)\/([^\/]+)/)
      id = $1
      title = $2
      self.code = IFRAME_TEMPLATE.gsub(/\|title\|/, title).gsub(/\|id\|/, id)
    end

    def resize_iframe
      return unless code
      self.code = code.gsub(/width="[0-9]+"/, 'width="420"')
      self.code = code.gsub(/height="[0-9]+"/, 'height="315"')
    end
end
