class UpverterWidget < Widget

  def self.model_name
    Widget.model_name
  end

  define_attributes [:code]
  attr_accessible :code
  # validates :code, presence: true
  before_save :resize_iframe

  def help_text
    ""
  end

  private
    def resize_iframe
      return unless code
      self.code = code.gsub(/width="[0-9]+"/, 'width="420"')
      self.code = code.gsub(/height="[0-9]+"/, 'height="315"')
    end
end
