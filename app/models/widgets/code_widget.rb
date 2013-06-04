require 'open-uri'
require 'pygments'

class CodeWidget < Widget

  LANGUAGES = {
    'C' => 'c',
    'C++' => 'cpp',
    'C#' => 'csharp',
    'Console' => 'console',
    'HTML' => 'html',
    'Java' => 'Java',
    'JavaScript' => 'js',
    'Python' => 'python',
    'Perl' => 'perl',
    'Ruby' => 'rb',
    'XML' => 'xml',
  }

  def self.model_name
    Widget.model_name
  end

  define_attributes [:formatted_content, :language]
  has_one :document, as: :attachable

  attr_accessible :document_attributes
  accepts_nested_attributes_for :document, allow_destroy: true
  before_validation :disallow_blank_file
  before_validation :guess_language_from_extension
  before_save :format_content

  def format_content
    return unless document and (document.file_changed? or language_changed?)

    begin
      file_url = if document.file_changed?
        "http://#{APP_CONFIG['default_host']}:#{APP_CONFIG['default_port']}#{document.file_url}"
      else
        document.file_url
      end

    rescue
      text = "Error opening file."
    end

    text = open(file_url).read
    self.formatted_content = Pygments.highlight(text, lexer: language)
  end

  def help_text
    "Add a file."
  end

  private
    def disallow_blank_file
      document.disallow_blank_file! if document
    end

    def guess_language_from_extension
    end
end
