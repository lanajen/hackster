require 'open-uri'
require 'pygments'

class CodeWidget < Widget
  define_attributes [:formatted_content, :language]
  has_one :document, as: :attachable

  attr_accessible :document_attributes
  accepts_nested_attributes_for :document, allow_destroy: true
  before_validation :guess_language_from_extension
  before_save :format_content

  def format_content
    return unless document and (document.changed? or language_changed?)
    file_url = case Rails.env
    when 'development'
      "http://#{APP_CONFIG['default_host']}:#{APP_CONFIG['default_port']}#{document.file_url}"
    when 'production'
      document.file_url
    end
    begin
      text = open(file_url).read
      self.formatted_content = Pygments.highlight(text, lexer: language)
    rescue
      self.formatted_content = "<pre><code>Error opening file.</code></pre>"
    end
  end

  def help_text
    "Add a file."
  end

  private
    def guess_language_from_extension

    end
end
